require "minitest/autorun"
require "set"

module Octopuses
  def simulate(filename, n, sync: false)
    return step(load(filename), n) unless sync

    sync_step(load(filename), 0, 0)
  end

  private

  def step(state, n, flashes = 0)
    return flashes if n <= 0

    (next_state, new_flashes) = flash(state.map { |row| row.map(&:succ) })

    step(next_state, n - 1, flashes + new_flashes)
  end

  def sync_step(state, n, new_flashes = 0)
    return n if new_flashes == state.length * state[0].length

    (next_state, new_flashes) = flash(state.map { |row| row.map(&:succ) })

    sync_step(next_state, n + 1, new_flashes)
  end

  def flash(state, flashing = true, flashed = Set.new)
    return [state, flashed.length] unless flashing

    flashers = coords(0, state.length, 0, state.first.length).filter { |(i, j)| state[i][j] > 9 }.to_set

    flash(
      state.each.with_index.map do |row, i|
        row.each.with_index.map do |cell, j|
          next 0 if flashers.include?([i, j]) || flashed.include?([i, j])

          cell + (flashers & neighbours(i, j)).length
        end
      end,
      flashers.any?,
      flashed | flashers
    )
  end

  def load(filename)
    File
      .readlines(filename)
      .map { |line| line.strip.split("").map(&:to_i) }
  end

  def pp(state)
    puts(*state.map(&:join))
  end

  def coords(y0, y1, x0, x1)
    [*y0...y1].product([*x0...x1])
  end

  def neighbours(y, x)
    [[y - 1, x], [y + 1, x], [y, x - 1], [y, x + 1], [y - 1, x - 1], [y + 1, x - 1], [y - 1, x + 1], [y + 1, x + 1]]
  end
end

class OctopusesTest < Minitest::Test
  include Octopuses

  def test_p1
    assert_equal 9, simulate("11/small_example.txt", 2)
    assert_equal 1656, simulate("11/example.txt", 100)
    assert_equal 1637, simulate("11/input.txt", 100)
  end

  def test_p2
    assert_equal 195, simulate("11/example.txt", 0, sync: true)
    assert_equal 242, simulate("11/input.txt", 0, sync: true)
  end
end
