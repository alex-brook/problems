require_relative "../spec_helper"
require "set"

class DayNine < Day
  def solve(filename, sneks=2)
    instructions = File
      .readlines(filename, chomp: true)
      .reverse_each
      .flat_map do |line| 
        [line.split.last.to_i, line.split.first]
      end

    direction = nil
    pairs = sneks.times.map { [0, 0] }
    visited = Set.new
    until instructions.none?
      # print_state(pairs, 10, 10)
      # p instructions
      # p direction
      # p visited
      # sleep 0.1
      current_instruction = instructions.pop

      if current_instruction.is_a? String 
        direction = current_instruction
        next
      elsif current_instruction <= 0
        next
      end

      instructions.push(current_instruction - 1)
      y_head, x_head = pairs.first
      pairs[0] = case direction
        in "U"
          [y_head + 1, x_head]
        in "D"
          [y_head - 1, x_head]
        in "L"
          [y_head, x_head - 1]
        in "R"
          [y_head, x_head + 1]
      end

      (0...sneks).each_cons(2) do |i_head, i_tail|
        y_head, x_head = pairs[i_head]
        y_tail, x_tail = pairs[i_tail]

        y_tail, x_tail = update_tail(direction, y_head, x_head, y_tail, x_tail)

        pairs[i_tail] = [y_tail, x_tail]
      end

      visited.add(pairs.last)
    end
    visited.size
  end

  def update_tail(direction, y_head, x_head, y_tail, x_tail)
    dist = distance(y_head, x_head, y_tail, x_tail)
    return [y_tail, x_tail] unless dist >= 2 

    same_row = y_head == y_tail
    same_column = x_head == x_tail
    increment_row = y_head > y_tail
    decrement_row = y_head < y_tail
    increment_column = x_head > x_tail
    decrement_column = x_head < x_tail

    result = [y_tail, x_tail]
    result[0] += 1 if increment_row
    result[0] -= 1 if decrement_row
    result[1] += 1 if increment_column
    result[1] -= 1 if decrement_column

    result
  end 

  def distance(y1, x1, y2, x2)
    Math.sqrt((x1 - x2)**2 + (y1 - y2)**2)
  end

  def print_state(pairs, width, height)
    grid = height.times.map { Array.new(width, ",") }
    pairs
      .each
      .with_index do |(y, x), index|
        if index == 0
          grid[y][x] = "H"
        else
          grid[y][x] = index
        end
      end

    puts grid.map(&:join).join("\n")
  end

  # part one
  it { expect(solve("days/9_example.txt", 2)).to eq 13 }
  it { expect(solve("days/9_input.txt", 2)).to eq 6266 }

  # part two
  it { expect(solve("days/9_example.txt", 10)).to eq 1 }
  it { expect(solve("days/9_example_2.txt", 10)).to eq 36 }
  it { expect(solve("days/9_input.txt", 10)).to eq 2369 }

end
