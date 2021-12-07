require 'minitest/autorun'

module Submarine
  def move(filename)
    move =
      File
        .readlines(filename)
        .group_by { |order| order.split[0] }
        .transform_keys(&:to_sym)
        .transform_values { |orders| orders.map { |order| order.split[1].to_i }.sum }

    move[:forward] * (move[:down] - move[:up])
  end

  def move_with_aim(filename)
    _aim, depth, dist =
      File
        .readlines(filename)
        .map(&:split)
        .map { |order| [order.first.to_sym, order.last.to_i] }
        .reduce([0, 0, 0]) do |(aim, depth, dist), (direction, amount)|
          case direction
          when :forward
            [aim, depth + (aim * amount), dist + amount]
          when :up
            [aim - amount, depth, dist]
          when :down
            [aim + amount, depth, dist]
          end
        end

    dist * depth
  end
end

class SubmarineTest < Minitest::Test
  include Submarine

  def test_p1
    assert_equal 150, move('2/example.txt')
    assert_equal 2_322_630, move('2/input.txt')
  end

  def test_p2
    assert_equal 900, move_with_aim('2/example.txt')
    assert_equal 2_105_273_490, move_with_aim('2/input.txt')
  end
end
