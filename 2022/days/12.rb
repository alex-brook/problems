require_relative "../spec_helper"

class DayTwelve < Day
  LOWERCASE_A = 97

  # https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Pseudocode
  def dijkstra(nodes, starts, goal)
    prev = {}
  
    dist = Hash.new(Float::INFINITY)
    dist[goal] = 0

    q = MinHeap.new
    q.insert(goal, 0)

    until q.empty?
      current = q.extract

      if starts.any? { _1 == current }
        start = current
        break
      end

      neighbours(nodes, current).each do |neighbour|
        alt = dist[current] + 1
        if alt < dist[neighbour] && q.include?(neighbour)
          dist[neighbour] = alt
          prev[neighbour] = current
          q.update(neighbour, alt)
        elsif alt < dist[neighbour]
          dist[neighbour] = alt
          prev[neighbour] = current
          q.insert(neighbour, alt)
        end
      end
    end

    walk(prev, start, goal)
  end

  def walk(prev, start, goal)
    path = []
    current = start
    until current == goal 
      path << current
      current = prev[current]
    end

    path
  end

  def part_two(nodes, prev, goal)
    lowest = nodes.filter_map { |coords, height| coords if height == 0 }

    lowest.map do |start|
      p start
      part_one(prev, start, goal).size
    end.min
  end

  def neighbours(nodes, (row, col))
    [[row - 1, col], [row + 1, col], [row, col - 1], [row, col + 1]]
      .filter { |coords| nodes.key? coords }
      .filter { |coords| nodes[[row, col]] - nodes[coords]  <= 1 }
  end

  def solve(filename, part=:one)
    start = nil
    goal = nil
    nodes = {}

    File
      .readlines(filename, chomp: true)
      .map(&:chars)
      .each
      .with_index do |row, row_index|
        row
          .each
          .with_index do |value, col_index|
            if value == "S"
              start = [row_index, col_index]
              value = "a"
            elsif value == "E"
              goal = [row_index, col_index]
              value = "z"
            end

            nodes[[row_index, col_index]] = value.ord - LOWERCASE_A 
          end
      end

    if part == :one
      dijkstra(nodes, [start], goal).size
    elsif part == :two
      starts = nodes.filter_map { |coords, elevation| coords if elevation == 0 }
      dijkstra(nodes, starts, goal).size
    end
  end

  it { expect(solve("days/12_example.txt")).to eq 31 }
  it { expect(solve("days/12_input.txt")).to eq 528 }

  it { expect(solve("days/12_example.txt", :two)).to eq 29 }
  it { expect(solve("days/12_input.txt", :two)).to eq 522 }
end
