require 'minitest/autorun'

module Submarine
  def execute_orders(filename)
    move = File
           .readlines(filename)
           .group_by { |order| order.split[0] } # Group by direction
           .transform_keys(&:to_sym)
           .transform_values { |direction| direction.sum { |order| order.split[1].to_i } }

    move[:forward] * (move[:down] - move[:up])
  end
end

class SubmarineTest < Minitest::Test
  include Submarine

  def test_p1
    assert_equal 150, execute_orders('2/example.txt')
    assert_equal 2_322_630, execute_orders('2/input.txt')
  end
end