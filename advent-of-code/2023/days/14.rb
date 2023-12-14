require_relative "../spec_helper"

class DayFourteen < Day

  require "set"

  # cascade the rocks upwards
  def cascade(m, n, fixed, rocks)
    spaces = Array.new(n, 0)
    m.times do |i|
      spaces.map!(&:succ)
      n.times do |j|
        if fixed[i] && fixed[i].include?(j)
          spaces[j] = 0
        elsif rocks[i] && rocks[i].include?(j)
          spaces[j] -= 1
          rocks[i].delete j
          rocks[i - spaces[j]] ||= Set.new
          rocks[i - spaces[j]].add j
        end
      end
    end
  end

  def parse_input(path)
    grid = File
      .readlines(path, chomp: true)
      .map! { _1.split("") }

    m = grid.size
    n = grid.first.size
    fixed = {}
    rocks = {}
    m.times do |i|
      n.times do |j|
        current = grid.dig(i, j)
        if current == "#"
          fixed[i] ||= Set.new
          fixed[i] << j
        elsif current == "O"
          rocks[i] ||= Set.new
          rocks[i] << j
        end
      end
    end

    [m, n, fixed, rocks]
  end

  def rotate(m, n, fixed, rocks)
    center_i = m.fdiv(2)
    center_j = n.fdiv(2)
    fixed2 = {}
    rocks2 = {}

    [[fixed, fixed2], [rocks, rocks2]].each do |(a, b)|
      a.each do |i, js|
        js.each do |j|
          ir = (i - center_i)
          jr = (j - center_j)
          temp = ir
          ir = (jr + center_i).to_i
          jr = (-temp + center_j).to_i - 1

          b[ir] ||= Set.new
          b[ir].add jr
        end
      end
    end

    [n, m, fixed2, rocks2]
  end

  def p1(path)
    m, n, fixed, rocks = parse_input(path)

    cascade(m, n, fixed, rocks)

    m.times.reduce(0) do |acc, i|
      next acc unless rocks[i]

      acc + rocks[i].size * (m - i)
    end
  end

  def serialize(rocks)= rocks.transform_values { _1.to_a.sort }.to_a.sort
  def deserialize(rocks)= rocks.to_h { |(key, val)| [key, val.to_set] } 

  def p2(path)
    m, n, fixed, rocks = parse_input(path)

    # find loop
    states = {}
    start_state = nil
    end_state = nil
    i = 0
    loop do
      start_state = serialize(rocks)

      4.times do
        cascade(m, n, fixed, rocks)
        m, n, fixed, rocks = rotate(m, n, fixed, rocks)
      end

      end_state = serialize(rocks)
      states[start_state] = end_state
      break if states.values.all? { states.key?(_1) }
    end

    starting = states.keys.first
    seen = Set.new
    i = 0
    cur = starting
    prev = nil
    until seen.include?(cur)
      seen.add cur
      prev = cur
      cur = states[cur]
      i += 1
    end

    loop_length = states.keys.index(prev) - states.keys.index(cur) + 1
    start_length = states.size - loop_length
    remainder = (1_000_000_000 - start_length) % loop_length

    cur = states.keys.first
    (start_length + remainder).times do |i|
      cur = states[cur]
    end
    rocks = deserialize(cur)
    m.times.reduce(0) do |acc, i|
      next acc unless rocks[i]

      acc + rocks[i].size * (m - i)
    end
  end

  it { expect(p1("days/14_example.txt")).to eq(136) }
  it { expect(p1("days/14_input.txt")).to eq(105249) }

  it  { expect(p2("days/14_example.txt")).to eq(64) }
  it { expect(p2("days/14_input.txt")).to eq(88680) }
end