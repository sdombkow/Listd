require 'barby/outputter'

module Barby

  class Outputter


    #A collection of rows - an array of arrays
    class PointMatrix < Array

      DEFAULT_XDIM = 1.0
      DEFAULT_YDIM = 1.0

      attr_writer :xdim, :ydim


      def initialize(*a, &b)
        # new([[t,f,t,f], [f,t,f,t], ...])
        if a[0].is_a?(Array) && a[0][0].is_a?(Array) && [true,false].include?(a[0][0][0])
          a[0] = a[0].map{|r| PointRow.new(self, r) }
        # new(['1010', '0101', ...])
        elsif a[0].is_a?(Array) && a[0][0].is_a?(String)
          a[0] = a[0].map{|s| PointRow.new(self, s) }
        end

        super(*a, &b)
      end


      def xdim
        @xdim || DEFAULT_XDIM
      end

      def ydim
        @ydim || DEFAULT_YDIM
      end


      def width
        inject(0){|m,r| r.width > m ? r.width : m }
      end

      def height
        inject(0){|s,r| s + r.height }
      end


      def to_s
        map{|r| r.to_s }
      end

      def inspect
        to_s
      end


      def dup
        self.class.new(map{|r| r.dup })
      end


    end


    class PointRow < Array

      attr_reader :matrix
      attr_accessor :xdim, :ydim


      def initialize(*a, &b)
        raise ArgumentError, 'PointRow must belong to a PointMatrix' unless a[0].is_a?(PointMatrix)
        @matrix = a.shift

        #Assume called with [t,f,t,f,..]
        if a[0].is_a?(Array) && [true, false].include?(a[0][0])
          a[0] = a[0].map{|b| Point.new(self, b) }
        #Assume called with '1010..'
        elsif a[0].is_a?(String)
          a[0] = a[0].split(//).map{|s| Point.new(self, s == '1') }
        end

        super(*a, &b)
      end


      def booleans
        map{|p| p.active? }
      end


      def xdim
        @xdim || matrix.xdim
      end

      def ydim
        @ydim || matrix.ydim
      end


      def width
        inject(0){|s,p| s + p.width }
      end

      def height
        inject(0){|m,p| p.height > m ? p.height : m }
      end


      def to_s
        inject(''){|s,p| s << (p.active ? '1' : '0') }
      end

      def inspect
        to_s
      end

      def ==(other)
        super #Just to say explicitly that equality should behave like in an array
      end


      def dup
        self.class.new(matrix, map{|p| p.dup })
      end

    end


    class Point

      attr_reader :row, :active
      attr_writer :width, :height, :color, :active
      alias active? active


      def initialize(row, active, opts={})
        @row = row
        self.active = active
      end


      def color
        @color || (active ? Color.new(0,0,0) : nil)
      end

      def width
        @width || row.xdim
      end

      def height
        @height || row.ydim
      end


      def ==(other)
        active == other.active &&
        width == other.width &&
        height == other.height &&
        color == other.color
      end


    end


    #TODO Add alpha
    class Color

      MIN_VALUE = 0
      MAX_VALUE = 255

      attr_reader :red, :blue, :green

      def initialize(r, b, g)
        self.red, self.blue, self.green = r, b, g
      end


      def red=(r)
        set_color(:red, r)
      end

      def blue=(b)
        set_color(:blue, b)
      end

      def green=(g)
        set_color(:green, g)
      end


      def ==(other)
        other.red == red && other.blue == blue && other.green == green
      end


    private

      def set_color(name, value)
        raise ArgumentError, "Value must be between 0-255" if value < MIN_VALUE || value > MAX_VALUE
        instance_variable_set("@#{name}", value)
      end


    end


  end

end
