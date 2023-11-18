require "minitest/autorun"
require "set"

module Vents
  def risk(filename)
    load(filename).then do |floor|
      low_points(floor).map { |row, col| floor[row][col] + 1 }.sum
    end
  end

  def basins(filename)
    load(filename).then do |floor|
      low_points(floor)
        .map { |point| bfs(floor, point) }
        .map(&:length)
        .sort_by(&:-@)
        .take(3)
        .reduce(&:*)
    end
  end

  private

  def neighbours(floor, row, col)
    [
      [row - 1, col],
      [row + 1, col],
      [row, col - 1],
      [row, col + 1],
    ].filter do |wrow, wcol|
      (0...floor.length).cover?(wrow) && (0...floor.first.length).cover?(wcol)
    end
  end

  def bfs(floor, start)
    visited = Set.new
    frontier = Queue.new
    frontier << start

    until frontier.empty?
      node = frontier.pop
      visited << node
      current_row, current_col = node

      neighbours(floor, current_row, current_col)
        .filter do |row, col|
        !visited.include?([row, col]) &&
          floor[row][col] >= floor[current_row][current_col] &&
          floor[row][col] < 9
      end
        .each { |neighbour| frontier << neighbour }
    end

    visited
  end

  def load(filename)
    File.readlines(filename).map { |row| row.strip.chars.map(&:to_i) }
  end

  def low_points(floor)
    (0...floor.length)
      .to_a
      .product((0...floor.first.length).to_a)
      .filter do |(row, col)|
      neighbours(floor, row, col)
        .map { |wrow, wcol| floor[wrow][wcol] }
        .filter { |depth| depth <= floor[row][col] }
        .none?
    end
  end
end

class VentsTest < Minitest::Test
  include Vents

  def test_p1
    assert_equal 15, risk("9/example.txt")
    assert_equal 508, risk("9/input.txt")
  end

  def test_p2
    assert_equal 1134, basins("9/example.txt")
    assert_equal 1_564_640, basins("9/input.txt")
  end
end
