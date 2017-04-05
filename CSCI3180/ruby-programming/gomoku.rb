# CSCI3180 Principles of Programming Languages
# --- Declaration ---
# I declare that the assignment here submitted is original except for source material explicitly
# acknowledged. I also acknowledge that I am aware of University policy and regulations on
# honesty in academic work, and of the disciplinary guidelines and procedures applicable to
# breaches of such policy and regulations, as contained in the website
# http://www.cuhk.edu.hk/policy/academichonesty/
# Assignment 2
# Name:			CHEONG Man Hoi
# Student ID:	1155043317
# Email Addr:	stephencheong623@yahoo.com.hk

class Gomoku
	def initialize()
		@turn = 'O'
		# Number of available positions (empty positions) on the 15 * 15 board
		@moves_left = 225
		# The actual 15 * 15 game board
		@board = Array.new(15){Array.new(15, ' ')}
		# The 17 * 32 board used to print to console
		@board_to_print = Array.new(17){Array.new(32, ' ')}

		# Initialize the board used to print to console
		# Initialize the first two rows
		for i in (0 .. 31)
			if i >= 23 && i % 2 != 0
				@board_to_print[0][i] = '1'
			end
			if i >= 3 && i % 2 != 0
				@board_to_print[1][i] = ((i - 3)/2)%10
			end
		end
		# Initialize the first two columns
		for i in (0 .. 16)
			if i >= 12
				@board_to_print[i][0] = '1'
			end
			if i >= 2
				@board_to_print[i][1] = (i - 2)%10
			end
		end
		# Initialize the rest of the board
		for i in (2 .. 16)
			for j in (2 .. 31)
				if j % 2 != 0
					@board_to_print[i][j] = '.'
				end
			end
		end
	end

	# The method to start the game
	def startGame()
		# Prompt the user for players' info
		# First player (O)
		while true do
			print ("First player is (1) Computer or (2) Human? ")
			key1 = gets()
			if key1.to_i == 1
				@player1 = Computer.new('O')
				puts ("Player O is Computer")
				break
			elsif key1.to_i == 2
				@player1 = Human.new('O')
				puts ("Player O is Human")
				break
			else
				puts ("Invalid input. Try again!")
			end
		end
		# Second player (X)
		while true do
			print ("Second player is (1) Computer or (2) Human? ")
			key2 = gets()
			if key2.to_i == 1
				@player2 = Computer.new('X')
				puts ("Player X is Computer")
				break
			elsif key2.to_i == 2
				@player2 = Human.new('X')
				puts ("Player X is Human")
				break
			else
				puts ("Invalid input. Try again!")
			end
		end

		# Game really starts
		# Variable used to store the players' moves
		move = Array.new(2)
		printBoard()
		while @moves_left > 0 do
			# It is player1's (O) move
			if @turn == 'O'
				# Get the next move from player1
				move = @player1.nextMove(@board)
				@board[move[0]][move[1]] = 'O'
				# Place in the corresponding position on the board used to print to console
				@board_to_print[move[0] + 2][move[1]*2 + 3] = 'O'
				puts ("Player O places to row #{move[0]}, col #{move[1]}")
				printBoard()
				# Check if the move results in player1 winning
				if @player1.checkWin(move[0], move[1], @board) == 1
					puts "Player O wins!"
					# Change the turn to nobody if player1 has won
					@turn = ' '
					break;
				end
				@turn = 'X'

			# It is player2's (X) moves
			elsif @turn == 'X'
				# Get the next move from player2
				move = @player2.nextMove(@board)
				@board[move[0]][move[1]] = 'X'
				# Place in the corresponding position on the board used to print to console
				@board_to_print[move[0] + 2][move[1]*2 + 3] = 'X'
				puts ("Player X places to row #{move[0]}, col #{move[1]}")
				printBoard()
				# Check if the move results in player2 winning
				if @player2.checkWin(move[0], move[1], @board) == 1
					puts "Player X wins!"
					# Change the turn to nobody if player2 has won
					@turn = ' '
					break;
				end
				@turn = 'O'
			end

			# One more place is occupied on the board
			@moves_left = @moves_left - 1
		end

		# If all 225 positions on the board have been filled yet no one has won
		if @turn != ' '
			puts ("Draw game!")
		end
	end

	def printBoard()
		@board_to_print.each{|x|
			puts x.join()
		}
	end
end

class Player
	@symbol
	def initialize(symbol)
		@symbol = symbol
	end

	def nextMove()
		
	end

	def symbol
		return @symbol
	end

	# The algorithm in the tutorial has been taken as reference
	def checkWin(row, col, board)
		# Check | direction
		flag = 0
		min = [row - 4, 0].max
		max = [row + 4, 14].min
		for i in (min .. max)
			if board[i][col] == self.symbol
				flag = flag + 1
				if flag == 5
					return 1
				end
			else
				flag = 0
			end
		end

		# Check -- direction
		flag = 0
		min = [col - 4, 0].max
		max = [col + 4, 14].min
		for i in (min .. max)
			if board[row][i] == self.symbol
				flag = flag + 1
				if flag == 5
					return 1
				end
			else
				flag = 0
			end
		end

		# Unlike in the | or the -- direction, in the \ or / direction, there are different
		# dependencies between the i_min, j_min, i_max and j_max

		# Check \ direction
		flag = 0
		if row > col
			j_min = [col - 4, 0].max
			i_min = row - (col - j_min)
			i_max = [row + 4, 14].min
			j_max = col + (i_max - row)
		elsif row <= col
			i_min = [row - 4, 0].max
			j_min = col - (row - i_min)
			j_max = [col + 4, 14].min
			i_max = row + (j_max - col)
		end
		for i, j in (i_min .. i_max).zip(j_min .. j_max)
			if board[i][j] == self.symbol
				flag = flag + 1
				if flag == 5
					return 1
				end
			else
				flag = 0
			end
		end

		# Check / direction
		flag = 0
		if row + col < 14
			j_min = [col - 4, 0].max
			i_max = row + (col - j_min)
			i_min = [row - 4, 0].max
			j_max = col + (row - i_min)
		elsif row + col >= 14
			i_max = [row + 4, 14].min
			j_min = col - (i_max - row)
			j_max = [col + 4, 14].min
			i_min = row - (j_max - col)
		end
		# We can't use for loop to loop through a decreasing range like (i_max .. i_min)...
		i = i_max
		for j in (j_min .. j_max)
			if board[i][j] == self.symbol
				flag = flag + 1
				if flag == 5
					return 1
				end
			else
				flag = 0
			end
			i = i - 1
		end

		# If 1 is not returned, no winning condition has been met
		return 0
	end
end

class Human < Player
	def nextMove(board)
		while true do
			print ("Player #{self.symbol}, make a move (row col): ")
			row, col = gets.chomp.split.map{|i|i.to_i}
			# Check the validity of the user's move
			if row < 0 or row > 14 or col < 0 or col > 14 or board[row][col] != ' '
				puts ("Invalid input. Try again!")
			else
				return [row, col]
				break;
			end
		end
	end
end

class Computer < Player
	# The algorithm provided in the tutorial
	def nextMove(board)
		blank = 0
		# Loop through all the available position on the game board
		for i in (0 .. 14)
			for j in (0 .. 14)
				if board[i][j] == ' '
					blank = blank + 1
					board[i][j] = self.symbol
					# If placing at the current position will cause the computer to win, choose it
					if self.checkWin(i, j, board) == 1
						return [i, j]
					end
					board[i][j] = ' '
				end
			end
		end

		# Generate a random position based on the number of blank spaces
		p = rand(blank) + 1

		temp = 0
		for i in (0 .. 14)
			for j in (0 .. 14)
				if board[i][j] == ' '
					temp = temp + 1
					if temp == p
						# No need to check the validity of this move, since it mush be empty
						return [i, j]
					end
				end
			end
		end
	end
end

# The main program
Gomoku.new.startGame()
