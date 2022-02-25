require "colorize"

class HumanPlayer
    def initialize
    end

    def get_pos
        puts "\nPlease enter the position to update the value (example '3,4'):"
        valid_input = false
        until valid_input
            position = gets.chomp.split(",").map(&:to_i)
            if position.length == 2 && position.all? { |coord| (0..8).include?(coord) }
                valid_input = true
            else
                puts "Invalid input. Please try again".red.bold
            end
        end
        position
    end

    def get_value
        abc = ("a".."z").to_a
        puts "\nPlease enter the value for this position (enter 0 to reset a tile):"
        valid_input = false
        until valid_input
            value = gets.chomp.to_i
            if (0..9).include?(value)
                valid_input = true
            else
                puts "Invalid input. Please only enter numbers from 1-9".red.bold
            end
        end
        value
    end
end