 require "colorize"

 class Tile
    def initialize(value, given)
        @value = value
        @given = given
    end

    attr_reader :value, :given

    def set_value(new_value)
        @value = new_value unless @given
    end

    def to_s
        text = @value == 0 ? "-" : "#{@value}"
        @given ? text.cyan.bold : text.light_white
    end
 end