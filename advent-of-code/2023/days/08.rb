require_relative "../spec_helper"

require "set"

class DayEight < Day
  def parse_input(path)
    edges = 
      File
        .readlines(path, chomp: true)
        .filter_map do |line|
          matched = line.scan(/[A-Z0-9]+/)
          next false if matched.none?

          matched
        end

    instructions = edges.shift.first

    adj = edges
      .group_by(&:first)
      .transform_values! do |val|
        val.flatten!.shift
        {
          "L" => val.first,
          "R" => val.last,
        }
      end

    [instructions, adj]
  end

  def p1(...)
    instructions, adj = parse_input(...)
    cur = "AAA"
    (0..).each do |i|
      cur = adj.dig(cur, instructions[i % instructions.size])
      return i + 1 if cur == "ZZZ"
    end
  end

  def move(instructions, adj, cur, cur_i)
    node = adj.dig(cur, instructions[cur_i % instructions.size])
    [node, cur_i + 1]
  end

  def detect_cycle(instructions, adj, start)
    slow = fast = start
    slow_i = fast_i = 0

    loop do
      slow, slow_i = move(instructions, adj, slow, slow_i)
      fast, fast_i = move(instructions, adj, fast, fast_i)
      fast, fast_i = move(instructions, adj, fast, fast_i)
      break if slow == fast && slow_i % instructions.size == fast_i % instructions.size
    end

    slow = start
    slow_i = 0
    until slow == fast && slow_i % instructions.size == fast_i % instructions.size
      slow, slow_i = move(instructions, adj, slow, slow_i)
    end

    len = 1
    fast, fast_i = move(instructions, adj, slow, slow_i)
    until slow == fast && slow_i % instructions.size == fast_i % instructions.size
      fast, fast_i = move(instructions, adj, fast, fast_i)
      len += 1
    end

    len
  end

  def p2(...)
    instructions, adj = parse_input(...)
    curs = adj
      .keys
      .filter_map { detect_cycle(instructions, adj, _1) if _1.end_with? "A" }
      .reduce(1) { |acc, x| acc.lcm(x) }
  end

  it { expect(p1("days/08_example_01.txt")).to eq(2) }
  it { expect(p1("days/08_example_02.txt")).to eq(6) }
  it { expect(p1("days/08_input.txt")).to eq(14893) }

  it { expect(p2("days/08_example_03.txt")).to eq(6) }
  it { expect(p2("days/08_input.txt")).to eq(10241191004509) }
end