require_relative "../spec_helper"
require "set"

class DayNine < Day
  def solve(filename)
    instructions = File
      .readlines(filename, chomp: true)
      .reverse_each
      .flat_map do |line| 
        [line.split.last.to_i, line.split.first]
      end

    direction = nil
    y_head = 0
    x_head = 0
    y_tail = 0
    x_tail = 0
    visited = Set.new
    until instructions.none?
      current_instruction = instructions.pop

      if current_instruction.is_a? String 
        direction = current_instruction
        next
      elsif current_instruction <= 0
        next
      end

      instructions.push(current_instruction - 1)

      y_head, x_head = case direction
        in "U"
          [y_head + 1, x_head]
        in "D"
          [y_head - 1, x_head]
        in "L"
          [y_head, x_head - 1]
        in "R"
          [y_head, x_head + 1]
      end

      y_tail, x_tail = update_tail(direction, y_head, x_head, y_tail, x_tail)
      visited.add([y_tail, x_tail])

    end

    visited.size
  end

  def update_tail(direction, y_head, x_head, y_tail, x_tail)
    dist = distance(y_head, x_head, y_tail, x_tail)
    return [y_tail, x_tail] unless dist >= 2 

    case direction
      in "U"
        [y_head - 1, x_head]
      in "D"
        [y_head + 1, x_head]
      in "L"
        [y_head, x_head + 1]
      in "R"
        [y_head, x_head - 1]
    end
  end 

  def distance(y1, x1, y2, x2)
    Math.sqrt((x1 - x2)**2 + (y1 - y2)**2)
  end

  it { expect(solve("days/9_example.txt")).to eq 13 }
  it { expect(solve("days/9_input.txt")).to eq 6266 }
end
