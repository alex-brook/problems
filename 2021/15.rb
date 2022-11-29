require "minitest/autorun"
require "lazy_priority_queue"
require "set"

module RefinedPQ
  refine MinPriorityQueue do
    def include?(element)
      @references.key? element
    end

    def priority(element)
      @references[element].key
    end
  end
end

using RefinedPQ

module Chiton
  def load(filename, dist)
    @costs = File.readlines(filename).map(&:strip).map(&:chars).map { |line| line.map(&:to_i) }
    @max_dist = dist

  end

  def cost(i, j)
    height = @costs.size
    width = @costs.first.size
    dist = (i / height) + (j / width)
    origin_i = i % height
    origin_j = j % width

    cost = @costs[origin_i][origin_j]
    total = cost + dist

    return (total % 10) + 1 if total >= 10
    total
  end

  def in_bounds?(i, j)
    i >= 0 && j >= 0 && ((i / @costs.size) < @max_dist || (i / @costs.size) == 0 ) && ((j / @costs.first.size) < @max_dist || (j / @costs.first.size) == 0)
  end

  def neighbours(i, j)
    [[i - 1, j], [i + 1, j], [i, j - 1], [i, j + 1]].filter { |(i, j)| in_bounds?(i, j) }
  end

  def h(i, j)
    last_i = @costs.size - 1
    last_j = @costs.first.size - 1
    Math.sqrt(((i - last_i)**2) + ((j - last_j)**2))
  end

  def goal(i, j)
    goal_i = (@costs.size * [@max_dist, 1].max) - 1
    goal_j = (@costs.first.size * [@max_dist, 1].max) - 1
    i == goal_i && j == goal_j
  end

  def make_path(parent, i, j)
    path = [[i,j]]
    while parent[[i, j]]
      path << parent[[i, j]]
      (i, j) = parent[[i, j]]
    end

    path[..-2].reverse
  end

  def astar(filename, dist = 0)
    load(filename, dist)
    open = MinPriorityQueue.new
    closed = Set.new
    parent = { [0, 0] => nil }
    g = { [0,0] => 0 }
    open.push [0, 0], 0

    until open.empty? 
      current = open.pop
      (i, j) = current
      return make_path(parent, *current).sum { |(i, j)| cost(i, j) } if goal(*current)
      # return make_path(parent, *current) if goal(*current)

      neighbours(i, j).each do |neighbour|
        neighbour_g = g[current] + cost(*neighbour)
        neighbour_h = h(*neighbour)
        neighbour_f = neighbour_g + neighbour_h

        next if closed.include? neighbour
        next if open.include?(neighbour) && open.priority(neighbour) <= neighbour_f

        if open.include?(neighbour)
          open.change_priority(neighbour, neighbour_f)
          g[neighbour] = neighbour_g
          parent[neighbour] = current
        else
          open.push(neighbour, neighbour_f)
          g[neighbour] = neighbour_g
          parent[neighbour] = current
        end
      end

      closed.add current
    end
  end
end

class ChitonTest < Minitest::Test
  include Chiton

  def test_p1
    assert_equal 40, astar("15/example.txt")
    assert_equal 739, astar("15/input.txt")
  end

  def test_p2
    assert_equal 315, astar("15/example.txt", 5)
    assert_equal 3040, astar('15/input.txt', 5)
  end
end
