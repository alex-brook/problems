require 'minitest/autorun'

module Vents
  def num_crosses(filename)
    lines = File
            .readlines(filename)
            .map { |line| line.gsub(/\A*->\A*|,/, ' ').split }
            .map { |line| line.map(&:to_i) }
            .map { |line| Line.new(*line) }
            .filter { |line| line.horizontal? || line.vertical? }

    xr = Range.new(*[*lines.map(&:x1), *lines.map(&:x2)].minmax)
    yr = Range.new(*[*lines.map(&:y1), *lines.map(&:y2)].minmax)
    sample = xr.map { |x| yr.map { |y| [x, y] } }.flatten(1)

    sample.sum do |(x, y)|
      intersections = lines.filter { |line| line.cover?(x, y) }.length
      intersections >= 2 ? intersections : 0
    end
  end

  class Line
    attr_accessor :x, :y, :x1, :x2, :y1, :y2

    def initialize(x1, y1, x2, y2)
      @x1 = x1
      @x2 = x2
      @y1 = y1
      @y2 = y2

      @x = x1..x2
      @y = y1..y2
    end

    def horizontal?
      @y1 == @y2
    end

    def vertical?
      @x1 == @y2
    end

    def cover?(x, y)
      @x.cover?(x) && @y.cover?(y)
    end

    def inspect
      "(#{@x.first},#{@y.first} -> #{@x.last},#{@y.last})"
    end
  end
end

class VentsTest < Minitest::Test
  include Vents

  def test_p1
    assert_equal 5, num_crosses('5/example.txt')
  end
end
