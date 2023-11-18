# frozen_string_literal: true

require "minitest/autorun"

module GammaEpsilon
  def read(filename)
    File.readlines(filename).map(&:strip)
  end

  def power_consumption(filename)
    gamma =
      read(filename).then do |nums|
        (0...nums.first.length).map { |pos| mcb(nums, pos) }
      end

    epsilon = gamma.map { |x| x == "1" ? "0" : "1" }

    [gamma, epsilon].map(&:join).map { |x| x.to_i(2) }.reduce(:*)
  end

  def life_support_rating(filename)
    nums = read(filename)

    oxygen = filter_until_one(nums) { |nums, index| mcb(nums, index) }.to_i(2)
    co2 = filter_until_one(nums) { |nums, index| lcb(nums, index) }.to_i(2)

    oxygen * co2
  end

  private

  def filter_until_one(nums, index = 0, &blk)
    return nums.first if nums.one?

    filter_until_one(
      nums.filter { |num| num[index] == blk.call(nums, index) },
      index + 1,
      &blk
    )
  end

  def until_one(nums, index = 0, &blk)
    return nums.first if nums.one?

    until_one(blk.call(nums, index), index + 1, &blk)
  end

  def mcb(nums, pos)
    nums
      .map { |x| x[pos] }
      .tally
      .to_a
      .max_by { |(bit, count)| [count, bit] }
      .first
  end

  def lcb(nums, pos)
    mcb(nums, pos) == "1" ? "0" : "1"
  end
end

class GammaEpsilonTest < Minitest::Test
  include GammaEpsilon

  def test_p1
    assert_equal 198, power_consumption("3/example.txt")
    assert_equal 3_813_416, power_consumption("3/input.txt")
  end

  def test_p2
    assert_equal 230, life_support_rating("3/example.txt")
    assert_equal 0, life_support_rating("3/input.txt")
  end
end
