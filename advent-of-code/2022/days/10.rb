require_relative "../spec_helper"

class DayTen < Day
  def execute(filename)
    cycles = {
      "addx" => 2,
      "noop" => 1,
    }

    snapshot_cycles = [20, 60, 100, 140, 180, 220]
    snapshots = {}
    screen = 6.times.map { Array.new(40, ".") }

    program = File
      .readlines(filename, chomp: true)
      .map do |line|
        opcode = line.split.first
        operand = line.split.last.to_i
        runtime = cycles[opcode]

        [opcode, operand, runtime]
      end
      .reverse

    x = 1
    cycle = 1
    until program.none?
      if snapshot_cycles.include? cycle
        snapshots[cycle] = x
      end

      screen_y, screen_x = pixel(cycle)

      lit = (x-1..x+1).cover? screen_x
      screen[screen_y][screen_x] = "#" if lit
      opcode, operand, runtime = program.pop

      # continue with multi-cycle instruction
      if runtime > 1
        program.push([opcode, operand, runtime - 1])
        cycle += 1
        next
      end

        x += operand
        cycle += 1
    end

    [snapshots, screen.map(&:join).join("\n")]
  end

  def pixel(cycle)
    width = 40

    [(cycle - 1) / width, (cycle - 1) % width]
  end

  def solve(filename)
    execute(filename)
      .first
      .map { |cycle, x| cycle * x }
      .sum
  end

  def solve_part_two(filename)
    execute(filename).last
  end

   it { expect(solve("days/10_example.txt")).to eq 13140 }
   it { expect(solve("days/10_input.txt")).to eq 14820 }

   it "displays the correct pixels for the example" do
     expected = <<~CRT.chomp
        ##..##..##..##..##..##..##..##..##..##..
        ###...###...###...###...###...###...###.
        ####....####....####....####....####....
        #####.....#####.....#####.....#####.....
        ######......######......######......####
        #######.......#######.......#######.....
     CRT

     expect(solve_part_two("days/10_example.txt")).to eq expected
   end

   it "displays the correct pixels for the input" do
     expected = <<~CRT.chomp
        ###..####.####.#..#.####.####.#..#..##..
        #..#....#.#....#.#..#....#....#..#.#..#.
        #..#...#..###..##...###..###..####.#..#.
        ###...#...#....#.#..#....#....#..#.####.
        #.#..#....#....#.#..#....#....#..#.#..#.
        #..#.####.####.#..#.####.#....#..#.#..#.
     CRT

     expect(solve_part_two("days/10_input.txt")).to eq expected
   end
end 
