require 'minitest/autorun'

module LaternFish
  def simulate(state, days)
    step(state.map { |value| Counter.new(value) }, days).length
  end

  def step(collection, n = 1)
    return collection if n.zero?

    step(collection.map(&:dec).flatten, n - 1)
  end

  class Counter
    INITIAL = 6
    NEW_INITIAL = INITIAL + 2

    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def dec
      @value -= 1

      if @value.negative?
        @value = INITIAL

        return [self, Counter.new(NEW_INITIAL)]
      end

      self
    end

    def inspect
      "~#{@value}"
    end
  end
end

class LanternFish < Minitest::Test
  include LaternFish

  def test_p2
    assert_equal 26, simulate([3, 4, 3, 1, 2], 18)
    assert_equal 5934, simulate([3, 4, 3, 1, 2], 80)
  end
end
