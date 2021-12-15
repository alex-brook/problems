# frozen_string_literal: true

require "minitest/autorun"

# Day 1 implementation
module Q1
  def self.times_increased(filename, window: 1)
    [
      File
        .readlines(filename)
        .map(&:to_i)
        .each_cons(window)
        .map(&:sum)
        .chunk_while { |before, after| after <= before }
        .count - 1,
      0,
    ].max
  end
end

# Tests for each part of Day 1
class Q1Test < Minitest::Test
  def test_p1
    assert_equal 7, Q1.times_increased("1/example.txt")
    assert_equal 0, Q1.times_increased("1/empty.txt")
    assert_equal 0, Q1.times_increased("1/singular.txt")
    assert_equal 1466, Q1.times_increased("1/1.txt")
  end

  def test_p2
    assert_equal 5, Q1.times_increased("1/example.txt", window: 3)
    assert_equal 0, Q1.times_increased("1/three.txt", window: 3)
    assert_equal 1, Q1.times_increased("1/four.txt", window: 3)
    assert_equal 1491, Q1.times_increased("1/1.txt", window: 3)
  end
end
