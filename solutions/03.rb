module Graphics
  class Canvas
    attr_reader :width, :height

    def initialize(width, height)
      @width  = width
      @height = height

      @canvas = Hash.new false
    end

    def set_pixel(x, y)
      @canvas[[y, x]] = true
    end

    def pixel_at?(x, y)
      @canvas[[y, x]]
    end

    def draw(figure)
      figure.draw_on(self)
    end

    def render_as(renderer)
      renderer.render(self)
    end
  end

  module Equality
    module AttributeEquality
      def hash
        equality_objects.hash
      end

      def eql?(other_object)
        equality_objects.eql? other_object.equality_objects
      end

      alias_method :==, :eql?
    end

    module AttributeComparable
      include Comparable

      def <=>(other_object)
        equality_objects <=> other_object.equality_objects
      end
    end

    def attribute_equality(*args, comparable: false)
      define_method :equality_objects do
        args.map { |attribute| public_send attribute }
      end

      include AttributeEquality
      include AttributeComparable if comparable
    end
  end

  module Renderers
    module BasicRenderer
      def render(canvas, pixels, line_break, template='%{canvas}')
        rows = 0.upto(canvas.height - 1).map do |y|
          row = 0.upto(canvas.width - 1).map do |x|
            pixels[canvas.pixel_at?(x, y)]
          end

          row.join('')
        end

        template % {canvas: rows.join(line_break)}
      end
    end

    class Ascii
      extend BasicRenderer

      PIXELS = {
        true  => '@'.freeze,
        false => '-'.freeze,
      }.freeze

      LINE_BREAK = "\n".freeze

      def self.render(canvas)
        super canvas, PIXELS, LINE_BREAK
      end
    end

    class Html
      extend BasicRenderer

      TEMPLATE = <<-TEMPLATE.freeze
        <!DOCTYPE html>
        <html>
        <head>
          <title>Rendered Canvas</title>
          <style type="text/css">
            .canvas {
              font-size: 1px;
              line-height: 1px;
            }
            .canvas * {
              display: inline-block;
              width: 10px;
              height: 10px;
              border-radius: 5px;
            }
            .canvas i {
              background-color: #eee;
            }
            .canvas b {
              background-color: #333;
            }
          </style>
        </head>
        <body>
          <div class="canvas">
            %{canvas}
          </div>
        </body>
        </html>
      TEMPLATE

      PIXELS = {
        true  => '<b></b>'.freeze,
        false => '<i></i>'.freeze,
      }.freeze

      LINE_BREAK = '<br>'.freeze

      def self.render(canvas)
        super canvas, PIXELS, LINE_BREAK, TEMPLATE
      end
    end
  end

  class Point
    extend Equality

    attr_reader        :x, :y
    attribute_equality :x, :y, comparable: true

    def initialize(x, y)
      @x = x
      @y = y
    end

    def draw_on(canvas)
      canvas.set_pixel(x, y)
    end

    def +(other_point)
      Point.new x + other_point.x, y + other_point.y
    end

    def -(other_point)
      Point.new x - other_point.x, y - other_point.y
    end

    def /(divisor)
      Point.new x / divisor, y / divisor
    end
  end

  class Line
    extend Equality

    attr_reader        :from, :to
    attribute_equality :from, :to

    def initialize(from, to)
      from, to = to, from if from > to

      @from = from
      @to   = to
    end

    def draw_on(canvas)
      if from == to
        canvas.set_pixel from.x, from.y
      else
        rasterize_on canvas
      end
    end

    private

    def rasterize_on(canvas)
      step_count    = [(to.x - from.x).abs, (to.y - from.y).abs].max
      delta         = (to - from) / step_count.to_r
      current_point = from

      step_count.succ.times do
        canvas.set_pixel(current_point.x.round, current_point.y.round)
        current_point = current_point + delta
      end
    end
  end

  class Rectangle
    extend Equality

    attr_reader        :left, :right
    attr_reader        :top_left, :top_right, :bottom_left, :bottom_right
    attribute_equality :top_left, :bottom_right

    def initialize(from, to)
      from, to = to, from if from > to

      @left  = from
      @right = to

      determine_corners
    end

    def draw_on(canvas)
      sides.each { |line| canvas.draw(line) }
    end

    private

    def determine_corners
      y_coordinates = [left.y, right.y]

      @top_left     = Point.new left.x,  y_coordinates.min
      @top_right    = Point.new right.x, y_coordinates.min
      @bottom_left  = Point.new left.x,  y_coordinates.max
      @bottom_right = Point.new right.x, y_coordinates.max
    end

    def sides
      [
        Line.new(top_left,    top_right   ),
        Line.new(top_right,   bottom_right),
        Line.new(bottom_left, bottom_right),
        Line.new(top_left,    bottom_left ),
      ]
    end
  end
end
