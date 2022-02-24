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

    attr_reader :grid

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

    def get_row_sectors
        row_sectors = Hash.new { |h, k| h[k] = [] }
        @grid.each.with_index do |row, i|
            current_row = row.select { |tile| tile if tile.value != 0 }
            row_sectors[i] = current_row.map { |tile| tile.value }
        end
        @row_sectors = row_sectors
    end

    def get_col_sectors
        col_sectors = Hash.new { |h, k| h[k] = [] }
        transposed = @grid.transpose
        transposed.each.with_index do |col, i|
            current_col = col.select { |tile| tile if tile.value != 0 }
            col_sectors[i] = current_col.map { |tile| tile.value }
        end
        @col_sectors = col_sectors
    end

    def get_quadrant_index(row, col)
        if row < 3 && col < 3
            target_quadrant = 0
        elsif row < 3 && col < 6
            target_quadrant = 1
        elsif row < 3 && col < 9
            target_quadrant = 2
        elsif row < 6 && col < 3
            target_quadrant = 3
        elsif row < 6 && col < 6
            target_quadrant = 4
        elsif row < 6 && col < 9
            target_quadrant = 5
        elsif row < 9 && col < 3
            target_quadrant = 6
        elsif row < 9 && col < 6
            target_quadrant = 7
        else
            target_quadrant = 8
        end
        target_quadrant
    end

    def get_quadrant_sectors
        quadrant_sectors = Hash.new { |h, k| h[k] = [] }

        @grid.each.with_index do |row, ri|
            row.each.with_index do |tile, ci|
                if tile.value != 0
                    target_quadrant = self.get_quadrant_index(ri, ci)
                    quadrant_sectors[target_quadrant] << tile.value
                end
            end
        end
        @quadrant_sectors = quadrant_sectors
    end
    
    def get_sectors
        self.get_col_sectors
        self.get_row_sectors
        self.get_quadrant_sectors
        true
    end

    def valid_row?(position, new_value)
        row, col = position
        is_valid = !@row_sectors[row].include?(new_value)
        unless is_valid
            text = "\nRow already contains that value!"
            puts text.red.bold
        end
        is_valid
    end

    def valid_col?(position, new_value)
        row, col = position
        is_valid = !@col_sectors[col].include?(new_value)
        unless is_valid
            text = "\nColumn already contains that value!"
            puts text.red.bold
        end
        is_valid
    end

    def valid_quadrant?(position, new_value)
        row, col = position
        quadrant = get_quadrant_index(row, col)
        is_valid = !@quadrant_sectors[quadrant].include?(new_value)
        unless is_valid
            text = "\nQuadrant already contains that value!"
            puts text.red.bold
        end
        is_valid
    end

    def valid_move?(position, new_value)
        args = [position, new_value]
        is_valid = self.valid_row?(*args) && self.valid_col?(*args) && self.valid_quadrant?(*args)
        is_valid
    end

    def update_sectors
    end
end