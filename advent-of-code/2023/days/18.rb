require_relative "../spec_helper"

class DayEighteen < Day
  DIRECTION = {
    "U" => [-1, 0],
    "3" => [-1, 0],

    "D" => [1, 0],
    "1" => [1, 0],

    "L" => [0, -1],
    "2" => [0, -1],

    "R" => [0, 1],
    "0" => [0, 1],
  }

  def points(instructions)
    points = [[0, 0]] 
    instructions.each_with_index do |(direction, length), idx| 
      origin_i, origin_j = points.last
      offset_i, offset_j = DIRECTION[direction]

      points << [
        origin_i + length * offset_i,
        origin_j + length * offset_j,
      ]
    end

    points
  end

  def squares(points)
    is, js = points.transpose
    lhs_total = 0
    rhs_total = 0
    (0...is.size - 1).each do |x|
      lhs_total += js[x] * is[x + 1]
      rhs_total += is[x] * js[x + 1]
    end

    # shoelace theorem
    area = (lhs_total - rhs_total).abs * 0.5
    perimeter = points.each_cons(2).reduce(0) do |acc, (p1, p2)|
      i1, j1 = p1
      i2, j2 = p2

      acc + (i1 - i2).abs + (j1 - j2).abs
    end

    # picks theorem
    inside = area - (perimeter / 2) + 1
    (inside + perimeter).to_i
  end

  def p1(path)
    instructions = 
      File
        .readlines(path, chomp: true)
        .map! do |line|
          direction, length, color = line.split

          [direction, length.to_i]
        end

    points(instructions).then { squares _1 }
  end

  def p2(path)
    instructions =
      File
        .readlines(path, chomp: true)
        .map! do |line|
          length, direction = /\(\#(\w{5})(\w{1})\)$/
            .match(line)
            .captures

            [direction, length.to_i(16)]
        end

    points(instructions).then { squares _1 }
  end

  it { expect(p1("days/18_example.txt")).to eq(62) }
  it { expect(p1("days/18_input.txt")).to eq(46394) }

  it { expect(p2("days/18_example.txt")).to eq(952408144115) }
  it { expect(p2("days/18_input.txt")).to eq(201398068194715) }
end