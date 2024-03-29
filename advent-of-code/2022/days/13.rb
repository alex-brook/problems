require_relative "../spec_helper"
require "json"

class DayThirteen < Day
 
  def compare(l, r)
    pair = [l, r]

    res = case pair
      in [Integer => left, ^left]
        nil
      in [Integer => left, Integer => right]
        left < right
      in [[], []]
        nil 
      in [[], _]
        true
      in [_, []]
        false
      in [[left_head, *left], [right_head, *right]]
        heads = compare(left_head, right_head)
        if heads.nil?
          compare(left, right)
        else
          heads
        end
      in [Array => left, Integer => right]
        compare(left, [right])
      in [Integer => left, Array => right]
        compare([left], right)
    end

    res
  end

  def comparison
    ->(a, b) { 
      c = compare(a, b)
      if c.nil?
        0
      elsif c
        -1
      else
        1
      end 
    }
  end

  def in_order?(l, r)
    comparison = compare(l, r)

    comparison || comparison.nil?
  end

  def pairs(filename)
    File
      .readlines(filename, chomp: true)
      .chunk_while { _1 != "" }
      .map do |pair|
        pair.pop if pair.size > 2

        pair.map { JSON.parse(_1) }
      end
  end

  def solve(filename)
    pairs(filename)
      .each
      .with_index
      .filter_map { |(a,b), index|index + 1 if in_order?(a, b) }
      .sum
  end

  def solve_part_two(filename)
    dividers = [[[2]], [[6]]]

    (pairs(filename) + dividers)
      .flatten(1)
      .sort(&comparison)
      .each
      .with_index
      .filter_map { |x, index| index + 1 if x == [2] || x == [6] }
      .reduce(&:*)
  end

 it { expect(in_order?([], [])).to eq true }
 it { expect(in_order?([1], [])).to eq false }
 it { expect(in_order?([], [1])).to eq true }
 it { expect(in_order?([1,1,3,1,1], [1,1,5,1,1])).to eq true }
 it { expect(in_order?([7,7,7,7], [7,7,7])).to eq false }
 it { expect(in_order?([], [3])).to eq true }
 it { expect(in_order?([[[]]], [[]])).to eq false }
 it { expect(in_order?([1, [2, [3, [4, [5,6,7]]]], 8, 9], [1, [2, [3, [4, [5, 6, 0]]]], 8, 9])).to eq false } 
 it { expect(in_order?([[1], [2,3,4]], [[1], 4])).to eq true }
 it { expect(in_order?([[4,4],4,4], [[4,4],4,4,4])).to eq true }

 it { expect(solve("days/13_example.txt")).to eq 13 }
 it { expect(solve("days/13_input.txt")).to eq 5684 }

 it { expect(solve_part_two("days/13_example.txt")).to eq 140 }
 it { expect(solve_part_two("days/13_input.txt")).to eq 22932 }
end
