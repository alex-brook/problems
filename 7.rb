# frozen_string_literal: true

require "minitest/autorun"

module Submarines
  def load(filename)
    File.readlines(filename).first.strip.split(",").map(&:to_i).sort
  end

  def align(filename)
    subs = load(filename)

    median = subs.length / 2

    subs.map { |sub| (sub - subs[median]).abs }.sum
  end

  def align2(filename)
    subs = load(filename)

    (0...subs.length).map do |meet_index|
      subs.map { |sub| dist(sub, meet_index) }.sum
    end.min
  end

  def dist(a, b)
    # The distance between a and b in the new scheme
    # is the triangular number corresponding to their
    # difference.
    n = (a - b).abs
    n * (n + 1) / 2
  end
end

class SubmarinesTest < Minitest::Test
  include Submarines

  def test_p1
    assert_equal 37, align("7/example.txt")
    assert_equal 344_605, align("7/input.txt")
  end

  def test_p2
    assert_equal 168, align2("7/example.txt")
    assert_equal 93_699_985, align2("7/input.txt")
  end
end
