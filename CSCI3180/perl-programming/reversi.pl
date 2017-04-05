# CSCI3180 Principles of Programming Languages
# ---Declaration---
# I declare that the assignment here submitted is original except for source material explicitly
# acknowledged. I also acknowledge that I am aware of University policy and regulations on honesty
# in academic work, and of the disciplinary guidelines and procedures applicable to breaches of
# such policy and regulations, as contained in the website
# http://www.cuhk.edu.hk/policy/academichonesty/
# Assignment 3
# Name: Stephen CHEONG Man Hoi
# Student ID: 1155043317
# Email Addr: stephencheong623@yahoo.com.hk

use warnings;

package Reversi;

sub new {
	# the actual 8 * 8 game board, initialized with dots
	my @board = ();
	for ($i = 0; $i < 8; $i++){
		@arr = ([".", ".", ".", ".", ".", ".", ".", "."]);
		push @board, @arr;
	}
	$board[3][3] = "O";
	$board[3][4] = "X";
	$board[4][3] = "X";
	$board[4][4] = "O";

	# the 9 * 17 board used to print to the console
	my @board_to_print = ();
	push @board_to_print, ([" ", " ", "0", " ", "1", " ", "2", " ", "3", " ", "4", " ", "5", " ", "6", " ", "7"]);
	for ($i = 0; $i < 8; $i++){
		@arr = (["$i", " ", ".", " ", ".", " ", ".", " ", ".", " ", ".", " ", ".", " ", ".", " ", "."]);
		push @board_to_print, @arr;
	}
	$board_to_print[4][8] = "O";
	$board_to_print[4][10] = "X";
	$board_to_print[5][8] = "X";
	$board_to_print[5][10] = "O";

	# player X & player O
	my ($black, $white);
	# the current turn
	my $turn = "X";
	# no. of "X" and no. of "O" on the board
	my $num_X = 2;
	my $num_O = 2;
	# no. of consecutive pass(es) made
	my $pass = 0;

	# prompt the user for the players' info
	print "First player is (1) Computer or (2) Human? ";
	my $key1 = <>;
	if ($key1 == 1){
		$black = Computer -> new("X");
		print "Player X is Computer\n";
	}
	elsif ($key1 == 2){
		$black = Human -> new("X");
		print "Player X is Human\n";
	}
	print "Second player is (1) Computer or (2) Human? ";
	my $key2 = <>;
	if ($key2 == 1){
		$white = Computer -> new("O");
		print "Player O is Computer\n";
	}
	elsif ($key2 == 2){
		$white = Human -> new("O");
		print "Player O is Human\n";
	}

	my $class = shift;
	my $self = {
		board => \@board,
		board_to_print => \@board_to_print,
		turn => $turn,
		black => $black,
		white => $white,
		num_X => $num_X,
		num_O => $num_O,
		pass => $pass,
	};

	bless $self, $class;
	return $self;
}

sub startGame {
	my $self = shift;
	my $moves_left = 60;
	my @move = (-1, -1);
	$self -> printBoard();
	print "Player X: ", $self -> {"num_X"}, "\n";
	print "Player O: ", $self -> {"num_O"}, "\n";
	while ($moves_left > 0 && $self -> {"pass"} != 2){
		if ($self -> {"turn"} eq "X"){
			my ($valid, $flip);
			($valid, $move[0], $move[1], $flip) = $self -> {"black"} -> nextMove($self -> {"board"}, $self -> {"board_to_print"});
			if ($valid == 1){
				print "Player X places to row ", $move[0], ", col ", $move[1], "\n";
				$self -> {"num_X"} += $flip;
				$self -> {"num_O"} -= $flip - 1;
				$moves_left--;
				$self -> {"pass"}--;
				if ($self -> {"pass"} < 0){
					$self -> {"pass"} = 0;
				}
			}
			else {
				print "Row ", $move[0], ", col ", $move[1], " is invalid! Player X passed!\n";
				$self -> {"pass"}++;
			}
			$self -> {"turn"} = "O";
			$self -> printBoard();
			print "Player X: ", $self -> {"num_X"}, "\n";
			print "Player O: ", $self -> {"num_O"}, "\n";
		}
		elsif ($self -> {"turn"} eq "O"){
			my ($valid, $flip);
			($valid, $move[0], $move[1], $flip) = $self -> {"white"} -> nextMove($self -> {"board"}, $self -> {"board_to_print"});
			if ($valid == 1){
				print "Player O places to row ", $move[0], ", col ", $move[1], "\n";
				$self -> {"num_O"} += $flip;
				$self -> {"num_X"} -= $flip - 1;
				$moves_left--;
				$self -> {"pass"}--;
				if ($self -> {"pass"} < 0){
					$self -> {"pass"} = 0;
				}
			}
			else {
				print "Row ", $move[0], ", col ", $move[1], " is invalid! Player O passed!\n";
				$self -> {"pass"}++;
			}
			$self -> {"turn"} = "X";
			$self -> printBoard();
			print "Player X: ", $self -> {"num_X"}, "\n";
			print "Player O: ", $self -> {"num_O"}, "\n";
		}
	}

	if ($self -> {"num_X"} > $self -> {"num_O"}){
		print "Player X wins!\n";
	}
	elsif ($self -> {"num_X"} < $self -> {"num_O"}){
		print "Player O wins!\n";
	}
	else {
		print "Draw game!\n";
	}
}

sub printBoard {
	my $self = shift;
	my ($i, $j);
	for ($i = 0; $i < 9; $i++){
		for ($j = 0; $j < 17; $j++){
			print $self -> {"board_to_print"} -> [$i][$j];
		}
		print "\n";
	}
}



package Player;

sub new {
	my $class = shift;
	my ($sym) = @_;
	my $self = {
		symbol => $sym,
	};
	bless $self, $class;
	return $self;
}

sub nextMove {

}

sub checkValid {
	my $self = shift;
	my $board = shift;
	my $board_to_print = shift;
	my $row = shift;
	my $col = shift;
	if ($row < 0 || $row > 7 || $col < 0 || $col > 7 || $board -> [$row][$col] ne "."){
		return 0, 0;
	}
	my $flip = 0;
	my $valid = 0;
	my $opt;
	if ($self -> {"symbol"} eq "X"){
		$opt = "O";
	}
	else {
		$opt = "X";
	}

	# up direction
	if ($row != 0){
		if ($board -> [$row - 1][$col] eq $opt){
			my $i = $row - 2;
			while ($i >= 0){
				if ($board -> [$i][$col] eq $opt){
					$i--;
				}
				elsif ($board -> [$i][$col] eq $self -> {"symbol"}) {
					$i++;
					while ($i != $row){
						$board -> [$i][$col] = $self -> {"symbol"};
						$board_to_print -> [$i + 1][($col + 1) * 2] = $self -> {"symbol"};
						$flip++;
						$i++;
					}
					$valid = 1;
					last;
				}
				else {
					last;
				}
			}
		}
	}
	# down direction
	if ($row != 7){
		if ($board -> [$row + 1][$col] eq $opt){
			my $i = $row + 2;
			while ($i <= 7){
				if ($board -> [$i][$col] eq $opt){
					$i++;
				}
				elsif ($board -> [$i][$col] eq $self -> {"symbol"}){
					$i--;
					while ($i != $row){
						$board -> [$i][$col] = $self -> {"symbol"};
						$board_to_print -> [$i + 1][($col + 1) * 2] = $self -> {"symbol"};
						$flip++;
						$i--;
					}
					$valid = 1;
					last;
				}
				else {
					last;
				}
			}
		}
	}
	# left direction
	if ($col != 0){
		if ($board -> [$row][$col - 1] eq $opt){
			my $j = $col - 2;
			while ($j >= 0){
				if ($board -> [$row][$j] eq $opt){
					$j--;
				}
				elsif ($board -> [$row][$j] eq $self -> {"symbol"}){
					$j++;
					while ($j != $col){
						$board -> [$row][$j] = $self -> {"symbol"};
						$board_to_print -> [$row + 1][($j + 1) * 2] = $self -> {"symbol"};
						$flip++;
						$j++;
					}
					$valid = 1;
					last;
				}
				else {
					last;
				}
			}
		}
	}
	# right direction
	if ($col != 7){
		if ($board -> [$row][$col + 1] eq $opt){
			my $j = $col + 2;
			while ($j <= 7){
				if ($board -> [$row][$j] eq $opt){
					$j++;
				}
				elsif ($board -> [$row][$j] eq $self -> {"symbol"}){
					$j--;
					while ($j != $col){
						$board -> [$row][$j] = $self -> {"symbol"};
						$board_to_print -> [$row + 1][($j + 1) * 2] = $self -> {"symbol"};
						$flip++;
						$j--;
					}
					$valid = 1;
					last;
				}
				else {
					last;
				}
			}
		}
	}
	# up-left direction
	if ($row != 0 && $col != 0){
		if ($board -> [$row - 1][$col - 1] eq $opt){
			my $i = $row - 2;
			my $j = $col - 2;
			while ($i >= 0 && $j >= 0){
				if ($board -> [$i][$j] eq $opt){
					$i--;
					$j--;
				}
				elsif ($board -> [$i][$j] eq $self -> {"symbol"}){
					$i++;
					$j++;
					while ($i != $row && $j != $col){
						$board -> [$i][$j] = $self -> {"symbol"};
						$board_to_print -> [$i + 1][($j + 1) * 2] = $self -> {"symbol"};
						$flip++;
						$i++;
						$j++;
					}
					$valid = 1;
					last;
				}
				else {
					last;
				}
			}
		}
	}
	# up-right direction
	if ($row != 0 && $col != 7){
		if ($board -> [$row - 1][$col + 1] eq $opt){
			my $i = $row - 2;
			my $j = $col + 2;
			while ($i >= 0 && $j <= 7){
				if ($board -> [$i][$j] eq $opt){
					$i--;
					$j++;
				}
				elsif ($board -> [$i][$j] eq $self -> {"symbol"}){
					$i++;
					$j--;
					while ($i != $row && $j != $col){
						$board -> [$i][$j] = $self -> {"symbol"};
						$board_to_print -> [$i + 1][($j + 1) * 2] = $self -> {"symbol"};
						$flip++;
						$i++;
						$j--;
					}
					$valid = 1;
					last;
				}
				else {
					last;
				}
			}
		}
	}
	# down-left direction
	if ($row != 7 && $col != 0){
		if ($board -> [$row + 1][$col - 1] eq $opt){
			my $i = $row + 2;
			my $j = $col - 2;
			while ($i <= 7 && $j >= 0){
				if ($board -> [$i][$j] eq $opt){
					$i++;
					$j--;
				}
				elsif ($board -> [$i][$j] eq $self -> {"symbol"}){
					$i--;
					$j++;
					while ($i != $row && $j != $col){
						$board -> [$i][$j] = $self -> {"symbol"};
						$board_to_print -> [$i + 1][($j + 1) * 2] = $self -> {"symbol"};
						$flip++;
						$i--;
						$j++;
					}
					$valid = 1;
					last;
				}
				else {
					last;
				}
			}
		}
	}
	# down-right direction
	if ($row != 7 && $col != 7){
		if ($board -> [$row + 1][$col + 1] eq $opt){
			my $i = $row + 2;
			my $j = $col + 2;
			while ($i <= 7 && $j <= 7){
				if ($board -> [$i][$j] eq $opt){
					$i++;
					$j++;
				}
				elsif ($board -> [$i][$j] eq $self -> {"symbol"}){
					$i--;
					$j--;
					while ($i != $row && $j != $col){
						$board -> [$i][$j] = $self -> {"symbol"};
						$board_to_print -> [$i + 1][($j + 1) * 2] = $self -> {"symbol"};
						$flip++;
						$i--;
						$j--;
					}
					$valid = 1;
					last;
				}
				else {
					last;
				}
			}
		}
	}


	if ($valid == 1){
		$board -> [$row][$col] = $self -> {"symbol"};
		$board_to_print -> [$row + 1][($col + 1) * 2] = $self -> {"symbol"};
		$flip++;
	}
	return $valid, $flip;
}



package Human;

@ISA = qw(Player);
sub new {
	my $class = shift;
	my ($sym) = @_;
	my $self = Player -> new($sym);
	bless $self, $class;
	return $self;
}

sub nextMove {
	my $self = shift;
	my $board = shift;
	my $board_to_print = shift;
	print "Player ", $self -> {"symbol"}, ", make a move (row col): ";
	my $line = <>;
	my @move = (-1, -1);
	($move[0], $move[1]) = split(" ", $line);
	my $valid = 0;
	my $flip = 0;
	($valid, $flip) = $self -> checkValid($board, $board_to_print, @move);
	return $valid, @move, $flip;
}




package Computer;

@ISA = qw(Player);
sub new {
	my $class = shift;
	my ($sym) = @_;
	my $self = Player -> new($sym);
	bless $self, $class;
	return $self;
}

sub nextMove {
	my $self = shift;
	my $board = shift;
	my $board_to_print = shift;
	my @move = (-1, -1);
	my @board_copy;
	my @board_to_print_copy;
	my $min_mobi = 64;
	my $valid = 0;
	my $flip;
	my ($i, $j);
	for ($i = 0; $i < 8; $i++){
		for ($j = 0; $j < 8; $j++){
			@board_copy = map {[@$_]} @$board;
			@board_to_print_copy = map {[@$_]} @$board_to_print;
			($valid, $flip) = $self -> checkValid(\@board_copy, \@board_to_print_copy, $i, $j);
			if ($valid == 1){
				my $mobi = 0;
				my ($valid_opt, $flip_opt);
				my @board_copy_opt;
				my @board_to_print_copy_opt;
				my ($k, $l);
				for ($k = 0; $k < 8; $k++){
					for ($l = 0; $l < 8; $l++){
						@board_copy_opt = map {[@$_]} @board_copy;
						@board_to_print_copy_opt = map {[@$_]} @board_to_print_copy;
						($valid_opt, $flip_opt) = $self -> checkValid(\@board_copy_opt, \@board_to_print_copy_opt, $k, $l);
						if ($valid_opt == 1){
							$mobi++;
						}
					}
				}
				if ($mobi < $min_mobi){
					$min_mobi = $mobi;
					$move[0] = $i;
					$move[1] = $j;
				}
			}
		}
	}
	($valid, $flip) = $self -> checkValid($board, $board_to_print, @move);
	return $valid, @move, $flip;
}



package main;
my $game = Reversi -> new();
$game -> startGame();
