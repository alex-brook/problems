require 'minitest/autorun'

module Vents
  def num_crosses(filename, criteria = nil)
    lines = File
            .readlines(filename)
            .map { |line| line.gsub(/\A*->\A*|,/, ' ').split }
            .map { |line| line.map(&:to_i) }
            .map { |line| Line.new(*line) }
            .filter { |line| criteria ? criteria.any? { |criterium| line.send(criterium) } : true }

    xr = (lines.map { |l| l.x.first }.min)..(lines.map { |l| l.x.last }.max)
    yr = (lines.map { |l| l.y.first }.min)..(lines.map { |l| l.y.last }.max)
    sample = xr.map { |x| yr.map { |y| [x, y] } }.flatten(1)

    sample.count { |(x, y)| lines.filter { |line| line.cover?(x, y) }.length >= 2 }
  end
  class Line
    attr_reader :x, :y

    def initialize(x1, y1, x2, y2)
      @x = x1 < x2 ? x1..x2 : x2..x1
      @y = y1 < y2 ? y1..y2 : y2..y1
    end

    def horizontal?
      @y.size == 1
    end

    def vertical?
      @x.size == 1
    end

    def diagonal?
      @x == @y
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
    assert_equal 5, num_crosses('5/example.txt', [:horizontal?, :vertical?])
    assert_equal 6687, num_crosses('5/input.txt')
  end

  # def test_p2
  #   assert_equal 12, num_crosses('5/example.txt', [:diagonal?])
  # end
end
