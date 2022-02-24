require "byebug"
require "colorize"
require_relative "0_tile"

class Board
    def self.from_file(puzzle_name)
        address = "./puzzle_files/" + puzzle_name
        layout = File.readlines(address).map(&:chomp).map { |line| line.split("") }
        layout.map do |row|
            row.map do |tile|
                value = tile.to_i
                given = value == 0 ? false : true
                params = [value, given]
                Tile.new(*params)
            end
        end
    end

    def initialize(puzzle_name)
        @grid = Board.from_file(puzzle_name)
    end

    def render
        header = "  ".light_white.on_light_black.bold
        (0..8).each do |i|
            need_breaker = i % 3 == 0 && i != 0
            header += " ".light_white.on_light_black.bold if need_breaker
            header += " " if need_breaker
            header += " #{i}".light_white.on_light_black.bold
            header += " ".light_white.on_light_black.bold if i == 8
        end
        puts header
        @grid.each.with_index do |line, i|
            need_breaker = i % 3 == 0 && i != 0
            puts "  ~".ljust(header.uncolorize.length,"~") if need_breaker

            key = " #{i}".light_white.on_light_black.bold
            line_string = " "
            line.each.with_index do |tile, i|
                need_breaker = i % 3 == 0 && i != 0
                line_string += "| " if need_breaker
                line_string += "#{tile.to_s} "
            end
            puts key + line_string
        end
        true
    end

    def [](position)
        row, col = position
        @grid[row][col]
    end

    def []=(position, new_value)
        row, col = position
        @grid[row][col].set_value(new_value)
    end

    def get_pos
        puts "\nPlease enter the position to update the value (example '3,4'):"
        valid_input = false
        until valid_input
            position = gets.chomp.split(",").map(&:to_i)
            if position.length == 2 && position.all? { |coord| (0..8).include?(coord) }
                valid_input = true
            else
                puts "Invalid input. Please try again"
            end
        end
        position
    end

    def legal_position(position)
        is_legal = !self[position].given
        unless is_legal
            text = "\nYou're trying to modify a given position, please chose another"
            puts text.red.bold
        end
        is_legal
    end

    def get_value
        abc = ("a".."z").to_a
        puts "\nPlease enter the value for this position:"
        valid_input = false
        until valid_input
            value = gets.chomp.to_i
            if (1..9).include?(value)
                valid_input = true
            else
                puts "Invalid input. Please only enter numbers from 1-9"
            end
        end
        value
    end

    def set_value(position, new_value)
        is_legal = self.legal_position(position)
        self[position] = new_value if is_legal
        is_legal
    end
end