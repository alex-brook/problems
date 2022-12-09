require_relative "../spec_helper"
require "set"

class DayEight < Day
  def solve(filename)
    grid = File
      .readlines(filename, chomp: true)
      .map { _1.chars.map(&:to_i) }

    height = grid.length
    width = grid.first.length

    down = [0].product (1...height - 1).to_a
    up = [height - 1].product (1...height - 1).to_a
    right = (1...width - 1).to_a.product [0]
    left = (1...width - 1).to_a.product [width - 1]
    corners = [[0,0], [0, width - 1], [height - 1, 0], [height - 1, width - 1]]

    visible = Set.new
    score = Hash.new(1)

    [down, up, right, left, corners].each do |direction|
      direction.each { |(y, x)| visible.add([y, x]) }
    end

    up.each { |(y, x)| flood(grid, visible, Hash.new(0), score, :up, y, x, grid[y][x]) }
    down.each { |(y, x)| flood(grid, visible, Hash.new(0), score, :down, y, x, grid[y][x]) }
    left.each { |(y, x)| flood(grid, visible, Hash.new(0), score, :left, y, x, grid[y][x]) }
    right.each { |(y, x)| flood(grid, visible, Hash.new(0), score, :right, y, x, grid[y][x]) }

    [visible.size, score.values.max]
  end

  def flood(grid, visible, scenery, score, direction, y, x, sight)
    y1, x1 = case direction
                    in :up
                      [y - 1, x] 
                    in :down
                      [y + 1, x]
                    in :left
                      [y, x - 1]
                    in :right
                      [y, x + 1]
                  end

    return unless in_bounds?(grid, y1, x1)

    # part one
    visible.add([y1, x1]) if grid[y1][x1] > sight

    # part two
    prev = grid[y][x]
    (prev + 1 ..9).each do |h|
      scenery[h] += 1
    end
    (0..prev).each do |h|
      scenery[h] = 1
    end
    score[[y1, x1]] *= scenery[grid[y1][x1]]

    flood(grid, visible, scenery, score, direction, y1, x1, [sight, grid[y1][x1]].max)
  end

  def in_bounds?(grid, y, x)
    height = grid.length
    width = grid.first.length

    y >= 0 && y < height && x >= 0 && x < width
  end

  it { expect(solve("days/8_example.txt")).to eq [21, 8] }
  it { expect(solve("days/8_input.txt")).to eq [1812, 315495] }
end
