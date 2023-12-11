require_relative "../spec_helper"

require "set"

class DayTen < Day
  def neighbours(grid, y, x, back_check=true)
    all = 
      case grid.dig(y, x)
      in "S"
        [[y - 1, x], [y + 1, x], [y, x - 1], [y, x + 1]]
      in "|"
        [[y - 1, x], [y + 1, x]]
      in "-"
        [[y, x - 1], [y, x + 1]]
      in "L"
        [[y - 1, x], [y, x + 1]]
      in "J"
        [[y - 1, x], [y, x - 1]]
      in "7"
        [[y + 1, x], [y, x - 1]]
      in "F"
        [[y + 1, x], [y, x + 1]]
      else
        []
      end

    all
      .filter { |ny, nx| ny >= 0 && nx >= 0 && ny < grid.size && nx < grid.first.size }
      .then { back_check ? _1.filter { |ny, nx| neighbours(grid, ny, nx, false).include?([y, x]) }  : _1}
  end

  def bfs(grid, sy, sx)
    seen = Set.new
    child = Hash.new { [] }
    max = 0
    q = [[sy, sx, 0]]

    while q.any?
      y, x, d = q.shift
      seen.add([y, x])
      max = [max, d].max
      neighbours(grid, y, x).each do |neighbour|
        next if seen.include?(neighbour)
        
        child[[y, x]] += [neighbour.take(2)]
        neighbour << (d + 1)
        q << neighbour
      end
    end

    [child, max]
  end

  def parse_input(path)
    grid = File
      .readlines(path, chomp: true)
      .map! { _1.split("") }

    sy = grid.index { _1.include? "S" }
    sx = grid[sy].index("S")

    [grid, sy, sx]
  end

  def p1(...)
    grid, sy, sx = parse_input(...)
    _child, max = bfs(grid, sy, sx)
    max
  end

  def points(child, sy, sx)
    acc = [[sy, sx]]
    ccw = child[[sy, sx]].first
    cw = child[[sy, sx]].last
    until ccw.nil? && cw.nil?
      unless cw.nil?
        acc.unshift(cw)
        cw = child[cw].first
      end
      unless ccw.nil?
        acc.push(ccw)
        ccw = child[ccw].first
      end
    end
    acc.uniq!
    acc
  end

  def p2(...)
    grid, sy, sx = parse_input(...)
    child, max = bfs(grid, sy, sx)
    points = points(child, sy, sx).to_set

    total = 0
    grid.size.times do |i|
      inside = false
      corner = nil
      grid[i].size.times do |j|
        on_pipe = points.include?([i, j])

        if on_pipe && grid.dig(i, j) == "|"
          inside = !inside
        elsif on_pipe && grid.dig(i, j) == "F"
          corner = "F"
        elsif on_pipe && grid.dig(i, j) == "L"
          corner = "L"
        elsif on_pipe && corner == "F" && grid.dig(i, j) == "J"
          corner = nil
          inside = !inside
        elsif on_pipe && corner == "F" && grid.dig(i, j) == "7"
          corner = nil
        elsif on_pipe && corner == "L" && grid.dig(i, j) == "J"
          corner = nil
        elsif on_pipe && corner == "L" && grid.dig(i, j) == "7"
          corner = nil
          inside = !inside
        elsif inside && !on_pipe
          total += 1
        end
      end
    end
    total
  end

  it { expect(p1("days/10_example_01.txt")).to eq(4) }
  it { expect(p1("days/10_example_02.txt")).to eq(4) }
  it { expect(p1("days/10_example_03.txt")).to eq(8) }
  it { expect(p1("days/10_example_04.txt")).to eq(8) }
  it { expect(p1("days/10_input.txt")).to eq(6842) }

  it { expect(p2("days/10_example_05.txt")).to eq(4) }
  it { expect(p2("days/10_example_06.txt")).to eq(4) }
  it { expect(p2("days/10_example_07.txt")).to eq(8) }
  it { expect(p2("days/10_example_08.txt")).to eq(10) }
  it { expect(p2("days/10_input.txt")).to eq(393) }
end