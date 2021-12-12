# frozen_string_literal: true

require 'minitest/autorun'

module LaternFish
  def simulate(filename, days)
    counter = Counter.new(filename)

    days.times { counter.step }

    counter.total
  end

  class Counter
    def initialize(filename)
      start = File.readlines(filename).first.strip.split(',').map(&:to_i).tally

      @state = (0..8).to_h { |n| [n, [0, 0]] }

      start.each { |k, v| @state[k][1] += v }
    end

    def step
      new_fish = @state[0].sum
      @state = @state.map { |k, _v| [k, @state[k + 1] || [new_fish, 0]] }.to_h
      @state[6][1] += new_fish
    end

    def total
      @state.values.flatten.sum
    end
  end
end

class LanternFishTest < Minitest::Test
  include LaternFish

  def test_p1
    assert_equal 26, simulate('6/example.txt', 18)
    assert_equal 5934, simulate('6/example.txt', 80)
    assert_equal 26_984_457_539, simulate('6/example.txt', 256)
    assert_equal 351_092, simulate('6/input.txt', 80)
  end

  def test_p2
    assert_equal 1_595_330_616_005, simulate('6/input.txt', 256)
  end
end
