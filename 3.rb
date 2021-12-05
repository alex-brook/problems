require 'minitest/autorun'

module GammaEpsilon
  def power_consumption(filename)
    lines = File.readlines(filename)
    word_length = lines.first.length - 1
    nums = lines.map { |num| num.to_i(2) }

    rate(nums, word_length, :gamma) * rate(nums, word_length, :epsilon)
  end

  # private

  def rate(nums, word_length, kind = :gamma, pos = 0, res = 0)
    return res if pos >= word_length

    # Most common bit at position pos
    mcb = nums.sum { |num| num >> pos & 1 } > (nums.length / 2)
    mcb = !mcb if kind == :epsilon

    rate(
      nums,
      word_length,
      kind,
      pos + 1,
      res + 2**pos * (mcb ? 1 : 0)
    )
  end
end

class GammaEpsilonTest < Minitest::Test
  include GammaEpsilon

  def test_p1
    assert_equal 198, power_consumption('3/example.txt')
    assert_equal 3813416, power_consumption('3/input.txt')
  end
end