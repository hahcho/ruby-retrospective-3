module HashUtil
  def self.integer_pair_hash(first, second)
    diagonal_index = first + second + 1
    first_diagonal_element = diagonal_index * (diagonal_index - 1) / 2
    first_diagonal_element + second
  end
end

module Graphics
  class Canvas
    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
    end

    def set_pixel(x, y)

    end

    def pixel_at?(x, y)

    end

    def draw(figure)

    end

    def render_as(renderer)

    end
  end

  # should make decision
  module Renderers
    class Html

    end

    class Ascii

    end
  end

  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def hash
      HashUtil::integer_pair_hash x, y
    end

    def eql? other
      other.x == x and other.y == y
    end
    alias_method :==, :eql?
  end

  class Line
    attr_reader :from, :to

    def initialize(from, to)
      @from, @to = from, to
    end

    def hash
      HashUtil::integer_pair_hash from.hash, to.hash
    end

    def eql? other
    end
    alias_method :==, :eql?
  end

  class Rectangle
    def eql? other
    end
    alias_method :==, :eql?
  end
end
