require "byebug"
require "colorize"
require_relative "0_tile"
require_relative "1_board"
require_relative "3_human_player"

class SudokuGame
    def self.create_player(player_type)
        player = player_type == "human" ? HumanPlayer.new : AiPlayer.new(@board)
    end

    def initialize(puzzle_name, player_type = "human")
        @board = Board.new(puzzle_name)
        @player = SudokuGame.create_player(player_type)
    end

    attr_reader :board

    def refresh_display
        system("clear")
        @board.render
    end

    def wait_and_refresh
        sleep(1)
        self.refresh_display
    end

    def play
        @board.get_sectors
        self.refresh_display
        solved = false
        until solved
            valid_move = false
            until valid_move
                legal_pos = false
                until legal_pos
                    position = @player.get_pos
                    legal_pos = @board.legal_position?(position)
                    self.wait_and_refresh unless legal_pos
                end
                new_value = @player.get_value
                valid_move = @board.valid_move?(position, new_value)
                self.wait_and_refresh unless valid_move
            end

            @board.set_value(position, new_value)
            @board.get_sectors
            solved = @board.solved?
            self.refresh_display
        end
    end
end

if __FILE__ == $PROGRAM_NAME
    puts "\nPlease input the name of the file to use, without the .txt:"
    puzzle_name = gets.chomp + ".txt"
    game = SudokuGame.new(puzzle_name)

    welcome_text = "WELCOME TO SUDOKU!"
    padding = (25 - welcome_text.length) / 2
    puts "\n" + ("#" * 25)
    puts " ".ljust(padding, " ") + welcome_text
    puts ("#" * 25)
    puts
    sleep(1)

    game.play

    puts "\nSuccess!"
end
