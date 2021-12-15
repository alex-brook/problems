# frozen_string_literal: true

require "minitest/autorun"
require "set"

module Segs
  #  5: 5 3 2
  #  6: 0 6 9
  #   0:      1:      2:      3:      4:
  #  aaaa    ....    aaaa    aaaa    ....
  # b    c  .    c  .    c  .    c  b    c
  # b    c  .    c  .    c  .    c  b    c
  #  ....    ....    dddd    dddd    dddd
  # e    f  .    f  e    .  .    f  .    f
  # e    f  .    f  e    .  .    f  .    f
  #  gggg    ....    gggg    gggg    ....

  #   5:      6:      7:      8:      9:
  #  aaaa    aaaa    aaaa    aaaa    aaaa
  # b    .  b    .  .    c  b    c  b    c
  # b    .  b    .  .    c  b    c  b    c
  #  dddd    dddd    ....    dddd    dddd
  # .    f  e    f  .    f  e    f  .    f
  # .    f  e    f  .    f  e    f  .    f
  #  gggg    gggg    ....    gggg    gggg

  def load(filename)
    File
      .readlines(filename)
      .map do |line|
      line
        .split("|")
        .map(&:strip)
        .map(&:split)
        .map { |section| section.map { |signal| Set[*signal.chars] } }
    end
  end

  def counts(filename)
    load(filename)
      .map do |(observations, output)|
      one = observations.find { |signal| signal.length == 2 }
      seven = observations.find { |signal| signal.length == 3 }
      four = observations.find { |signal| signal.length == 4 }
      eight = observations.find { |signal| signal.length == 7 }

      output.count { |o| [one, seven, four, eight].include? o }
    end
      .sum
  end

  def segs_to_i(filename)
    load(filename)
      .map do |(observations, output)|
      one = observations.find { |signal| signal.length == 2 }
      seven = observations.find { |signal| signal.length == 3 }
      four = observations.find { |signal| signal.length == 4 }
      eight = observations.find { |signal| signal.length == 7 }

      five_three_two = observations.filter { |signal| signal.length == 5 }
      three = five_three_two.find { |signal| (signal & one).length == 2 }
      two = five_three_two.find { |signal| (signal & four).length == 2 }
      five = five_three_two.find { |signal| signal != three && signal != two }

      zero_six_nine = observations.filter { |signal| signal.length == 6 }
      six = zero_six_nine.find { |signal| (signal & one).length == 1 }
      nine = zero_six_nine.find { |signal| (signal & four).length == 4 }
      zero = zero_six_nine.find { |signal| signal != six && signal != nine }

      lookup =
        [zero, one, two, three, four, five, six, seven, eight, nine].each
          .with_index.to_h { |digit, index| [digit, index] }

      output.map { |digit| lookup[digit] }.map(&:to_s).join.to_i
    end
      .sum
  end
end

class SegsTest < Minitest::Test
  include Segs

  def test_p1
    assert_equal 26, counts("8/example.txt")
    assert_equal 456, counts("8/input.txt")
  end

  def test_p2
    assert_equal 61_229, segs_to_i("8/example.txt")
    assert_equal 1_091_609, segs_to_i("8/input.txt")
  end
end
