require_relative "../spec_helper"

require "set"
require "lazy_priority_queue"

module PQ
  refine LazyPriorityQueue do
    def include?(element)
      !!@references[element]
    end
  end
end
using PQ

class DaySeventeen < Day
  class Step
    DIRECTION = {
      up: [-1, 0],
      down: [1, 0],
      left: [0, -1],
      right: [0, 1],
    }
    ROTATE = {
      up: [:up, :left, :right],
      down: [:down, :left, :right],
      left: [:left, :up, :down],
      right: [:right, :up, :down],
    }

    attr_accessor :i, :j, :direction, :length

    def initialize(i, j, direction, length)
      @i = i
      @j = j
      @direction = direction
      @length = length
    end

    def max_length
      3
    end

    def to_s
      "<Step (#{i}, #{j}) direction=#{direction} length=#{length}>"
    end

    def in_bounds?(grid)
      i >= 0 && j >= 0 && i < grid.size && j < grid.first.size
    end

    def valid?(grid)
      in_bounds?(grid) && length <= max_length
    end

    def hash
      [i, j, direction, length].hash
    end

    def eql?(obj)
      obj.is_a?(Step) && obj.hash == hash
    end

    def neighbours(grid)
      ROTATE[direction].map do |d|
        di, dj = DIRECTION[d]
        base_length = d == direction ? length : 0
        Step.new(i + di, j + dj, d, base_length + 1)
      end
      .filter { _1.valid?(grid) }
    end
  end

  class P2Step < Step
    def max_length
      10
    end

    def neighbours(grid)
      can_rotate = length >= 4
      if can_rotate
        ROTATE[direction].map do |d|
          di, dj = DIRECTION[d]
          base_length = d == direction ? length : 0
          P2Step.new(i + di, j + dj, d, base_length + 1)
        end
      else
        di, dj = DIRECTION[direction]
        [P2Step.new(i + di, j + dj, direction, length + 1)]
      end
      .filter { _1.valid?(grid) }
    end
  end

  def shortest_path(path, klass=Step)
    grid = File
      .readlines(path, chomp: true)
      .map!(&:chars)

    dist = Hash.new { Float::INFINITY }
    prev = {}
    q = MinPriorityQueue.new

    initial_distance = 0
    initial_node = klass.new(0, 0, :right, 1)
    dist[initial_node] = initial_distance
    q.push(initial_node, initial_distance)

    until q.empty?
      u = q.pop
      # puts "Processing #{u}"
      u.neighbours(grid).each do |v|
        # puts "\t #{v}"
        alt = dist[u] + grid.dig(v.i, v.j).to_i
        if alt < dist[v] && q.include?(v)
          dist[v] = alt
          prev[v] = u
          q.decrease_key(v, alt)
        elsif alt < dist[v]
          dist[v] = alt
          prev[v] = u
          q.push(v, alt)
        end
      end
    end

    [grid, prev, dist]
  end

  def print_path(grid, prev, best)
    path = {}
    u = best
    until u.nil?
      path[[u.i, u.j]] = u
      u = prev[u]
    end

    grid.size.times do |i|
      row = ""
      grid.first.size.times do |j|
        if u = path[[i, j]]
          case u.direction
          in :up then row << "^"
          in :down then row << "v"
          in :left then row << "<"
          in :right then row << ">"
          end
        else
          row << grid.dig(i, j)
        end
      end
      puts row
    end

    puts "#{path.values.map { grid.dig(_1.i, _1.j)}} #{path.values.sum { grid.dig(_1.i, _1.j).to_i }}"
  end

  def p1(path)
    grid, prev, dist = shortest_path(path, Step)

    best = dist.keys.min_by do |u|
      next Float::INFINITY unless u.i == grid.size - 1 && u.j == grid.first.size - 1

      dist[u]
    end
    dist[best]
  end

  def p2(path)
    grid, prev, dist = shortest_path(path, P2Step)

    is_left_point = ->(u) { u.i == grid.size - 1 && u.j == grid.first.size - 4 && u.length <= 6 && u.direction == :right }
    is_up_point = ->(u) { u.j == grid.first.size - 1 && u.i == grid.size - 4 && u.length <= 6 && u.direction == :down }

    best = dist.keys.min_by do |u|
      next Float::INFINITY unless is_left_point[u] || is_up_point[u]
      dist[u]
    end

    best_dist = dist[best]
    if is_left_point[best]
      (best.j + 1...grid.first.size).each do |j|
        best_dist += grid.dig(grid.size - 1, j).to_i
      end
      best_dist
    elsif is_up_point[best]
      (best.i + 1...grid.size).each do |i|
        best_dist += grid.dig(i, grid.first.size - 1).to_i
      end
      best_dist
    else
      raise
    end
  end

  it { expect(p1("days/17_example_01.txt")).to eq(102) }
  it { expect(p1("days/17_input.txt")).to eq(722) }

  it { expect(p2("days/17_example_01.txt")).to eq(94) }
  it { expect(p2("days/17_example_02.txt")).to eq(71) }
  it { expect(p2("days/17_input.txt")).to eq(894) }
end