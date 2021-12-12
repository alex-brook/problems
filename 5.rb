# frozen_string_literal: true

require 'minitest/autorun'

module Vents
  def num_crosses(filename, _criteria = nil)
    lines =
      File
        .readlines(filename)
        .map { |line| line.gsub(/\A*->\A*|,/, ' ').split }
        .map { |line| line.map(&:to_i) }
        .map { |line| Line.new(*line) }
        .map(&:points)
        .flatten(1)
        .tally
        .count { |_point, intersections| intersections >= 2 }
  end

  class Line
    def initialize(x1, y1, x2, y2)
      @x1 = x1
      @x2 = x2
      @y1 = y1
      @y2 = y2

      @xr = Range.new(*[@x1, @x2].sort)
      @yr = Range.new(*[@y1, @y2].sort)

      return if x1 == x2

      @m = (y2 - y1) / (x2 - x1)
      @c = y1 - @m * x1
    end

    def points
      return @yr.map { |y| [@xr.first, y] } if @x1 == @x2

      @xr.map { |x| [x, @m * x + @c] }
    end
  end
end

class VentsTest < Minitest::Test
  include Vents

  def test_p1
    # assert_equal 5, num_crosses('5/example.txt', %i[horizontal? vertical?])
    # assert_equal 6687, num_crosses('5/input.txt', %i[horizontal? vertical?])
  end

  def test_p2
    assert_equal 12, num_crosses('5/example.txt', %i[diagonal?])
    assert_equal 12, num_crosses('5/input.txt', %i[diagonal?])
  end
end
