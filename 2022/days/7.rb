require_relative "../spec_helper"
require "set"

class DaySeven < Day

  def pwd(stack)
    stack.join("/").chars.drop(1).join
  end

  def walk(filename)
    children, size, _stack = File
      .foreach(filename)
      .drop(1)
      .reduce([Hash.new { Set.new }, Hash.new(0), ["/"]]) do |(children, size, stack), line|
        cur_pwd = pwd(stack)

        if /\A\$ cd \.\./.match?(line)
          stack.pop
        elsif /\A\$ cd (.+)/.match(line)&.captures in [child_directory]
          stack.push child_directory
          child_pwd = pwd(stack)
          children[cur_pwd] = children[cur_pwd].add(child_pwd)
        elsif /\A(\d+) (.+)/.match(line)&.captures in [fsize, fname]
          stack.push fname
          child_pwd = pwd(stack)
          children[cur_pwd] = children[cur_pwd].add(child_pwd)
          size[child_pwd] = fsize.to_i
          stack.pop
        end

        [children, size, stack]
      end

    compute_total_sizes("", children, size)

    [children, size] 
  end

  def compute_total_sizes(current, children, size)
    return size[current] if size.key? current 

    size[current] = children[current].sum { compute_total_sizes(_1, children, size) }
  end

  def solve(filename)
    children, size = walk(filename)

    size
      .filter { children.key? _1 } # only directories
      .filter_map { |key, value| value if value <= 100_000 }
      .sum
  end

  def solve_part_two(filename)
    children, size = walk(filename)

    free = 70_000_000 - size[""]

    size
      .filter { children.key? _1 }
      .filter_map { |key, value| value if value + free >= 30_000_000 }
      .min
  end

  it { expect(solve("days/7_example.txt")).to eq 95437 }
  it { expect(solve("days/7_input.txt")).to eq 1667443 }

  it { expect(solve_part_two("days/7_example.txt")).to eq 24933642 }
  it { expect(solve_part_two("days/7_input.txt")).to eq 8998590 }
end
