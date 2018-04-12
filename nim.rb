=begin
    nim.rb -- A game of NIM in which the program uses reinforcement learning from past
    games via temporal difference learning (TD-learing) with U-values to learn how to
    play a good game of NIM.

    By Eli Anderson
=end

# calculate_u_vals() -- calculates the new Q-vals in the 2D array and stores it to u_vals.txt
# => comp_win: boolean, tells whether the computer won the game or not
# => u_vals: 2D array, the array of u_vals
# => alpha: float, learning rate (0.0-1.0)
# => gamme: float, discount factor (usually 1.0)
# => comp_moves: hash, contains the computer's moveset from the completed game
def update_u_vals(comp_win, u_vals, alpha, gamma, comp_moves)
    # set the reward based on comp_win
    if comp_win == true then reward = 1 else reward = -1 end
    # update the appropriate values
    comp_moves.each do |key, val|
        curr_val = u_vals[key][val]
        u_vals[key][val] = curr_val + alpha * (reward + (gamma * (curr_val+reward)) - curr_val)
    end

    # record the new values to u_vals.txt
    File.open("u_vals.txt", "w") do |file|
        u_vals.each do |i|
            i.each do |val|
                file.write("#{val} ")
            end
            file.write("\n")
        end
    end
end

# to erase u_vals.txt and have the computer learn from anew
def restart_learning(response)
    if response == 'Y'
        if File.file?("u_vals.txt")
            File.delete("u_vals.txt")
        end
    end
end

# begin the game
puts "Welcome to Eli's game of NIM! Here are the rules of NIM: "
puts "---------------------------------------------------------------------------"
puts "There are 12 sticks at the beginning of the game. Each player takes turns
to remove 1-4 sticks from the pile. For this program, the computer will always
have the first turn. The winner is whoever takes the last stick."
puts "---------------------------------------------------------------------------"
puts "Would you like restart the computer's learning?
Respond Y for learning from scratch, and N to use its past knowledge:"
response = gets.chop
restart_learning(response)

# create the array containing the U-values, or.fill an array with the appropriate values
# from the last game depending on the user's previous input
filename = "u_vals.txt"
if File.file?(filename) # if it does exist
    u_vals = Array.new(12) {Array.new(4)} # creates empty 2D array using a Ruby block
    i = 0
    file = File.readlines(filename).each do |line|
        #puts line # (uncomment to get the updated u-values from last game)
        val_line = line.split(" ")
        u_vals[i] = val_line.map {|ele| ele.to_f} # convert u_vals to floats
        i += 1
    end
else
    # fill u_vals up with zeros, except for some initial values for the definitive win
    u_vals = [[1,-1,-1,-1],[-1,1,-1,-1],[-1,-1,1,-1],[-1,-1,-1,1],[0,0,0,0],[0,0,0,0],[0,0,0,0],
    [0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
end

# this is how my u-value indexing works...
#    three_sticks = u_vals[2].max
#    to_take = u_vals[2].index(three_sticks) + 1
#    puts "U-value with 3 sticks remaining : #{three_val}, (takes #{to_take} sticks)"

# the actual game
sticks_remaining = 12
to_go = 'C' # computer goes first
comp_moves = Hash.new # to keep track of moves the computer makes for more efficient updating
alpha = 0.5 # set the alpha value
gamma = 1.0 # set the gamma value

while sticks_remaining != 0
    # computer's turn
    if to_go == 'C'
        puts "It is the computer's turn."
        # if the maximum u_vals are equivalent for one selection, choose random one from those equivalent
        row = u_vals[sticks_remaining-1]
        if row.count(row.max) > 1
            equivalent = []
            for i in 0..(row.length-1)
                # compare u_val with max u_val
                if row[i] == row.max
                    # if equivalent, append that index to `equivalent`
                    equivalent.push(i+1)
                end
            end
            num = equivalent.sample
        # one maximum q-val
        else
            u_val = row.max
            num = row.index(u_val) + 1
        end
        # record the computer's move
        comp_moves[sticks_remaining-1] = num - 1
        sticks_remaining -= num
        puts "The computer has taken #{num} sticks; there are #{sticks_remaining} remaining."
        to_go = 'H'

    # player's turn
    else
        puts "It is your turn. How many sticks will you take?"
        while true
            num = gets.chop.to_i
            if num == 0
                puts "You can't take zero sticks, but nice try... Choose a different number: "
            elsif num > sticks_remaining
                puts "You can't take more sticks than there are... Choose a different number: "
            elsif num > 4
                puts "You can't take more than four sticks... Choose a different number: "
            else
                print "You have taken #{num} sticks; "
                break
            end
        end
        sticks_remaining -= num
        puts "There are #{sticks_remaining} sticks remaining."
        to_go = 'C'
    end
end

# END OF GAME #
if to_go == 'C'
    puts "You are the winner!"
    update_u_vals(false, u_vals, alpha, gamma, comp_moves)
else
    puts "The computer has won. Sad!"
    update_u_vals(true, u_vals, alpha, gamma, comp_moves)
end
