require_relative "../spec_helper"

class DayFourteen < Day
  ROCK = "#"
  AIR = "."
  SAND = "o"

  def build(filename, floor=true)
    starting_state = {
      map: Hash.new(AIR),
      lb_x: Float::INFINITY,
      ub_x: -Float::INFINITY,
      lb_y: Float::INFINITY,
      ub_y: -Float::INFINITY,
      sand: 0,
    }
    File
      .readlines(filename, chomp: true)
      .map do |line|
        line
          .split(" -> ")
          .map { _1.split(",").map(&:to_i) }
      end
      .reduce(starting_state) do |acc, path|
        path
          .each_cons(2) do |(left_x, left_y), (right_x, right_y)|
            acc[:lb_x] = [acc[:lb_x], left_x, right_x].min
            acc[:ub_x] = [acc[:ub_x], left_x, right_x].max
            acc[:lb_y] = [acc[:lb_y], left_y, right_y].min
            acc[:ub_y] = [acc[:ub_y], left_y, right_y].max
            vertical = left_x - right_x == 0

            if vertical
              Range
                .new(*[left_y, right_y].sort)
                .each do |y|
                  acc[:map][[left_x, y]] = ROCK
                end
            else
              Range
                .new(*[left_x, right_x].sort)
                .each do |x|
                  acc[:map][[x, left_y]] = ROCK
                end
            end
          end

        acc
      end
      .then do |state|
        next unless floor
        
        original_ub = state[:ub_y]
        state[:map].default_proc = ->(hash, key) {
          key.last == original_ub + 2 ? ROCK : AIR
        }
        state
      end
  end

  def fall(state, x=500, y=0)
    state[:map][[x,y]] = SAND

    abyss = y > state[:ub_y]
    neighbours = [[x, y + 1], [x - 1, y + 1], [x + 1, y + 1]]
      .filter { free?(state, *_1) }  

    if abyss || neighbours.any?
      state[:map][[x,y]] = AIR
    else
      state[:sand] += 1
    end

    if !abyss && neighbours.any?
      new_x, new_y = neighbours.first
      fall(state, new_x, new_y)
    end
  end

  def free?(state, x, y)
    state[:map][[x,y]] == AIR
  end

  def solve(filename)
    state = build(filename)
    sand = state[:sand]
    loop do
      fall(state)

      break if state[:sand] == sand
      sand = state[:sand]
    end

    sand
  end

  def solve_part_two(filename)
    state = build(filename, true)
    state[:ub_y] += 3
    until state[:map][[500, 0]] == SAND do 
      fall(state)
    end

    state[:sand]
  end

  it { expect(solve("days/14_example.txt")).to eq 24 }
  it { expect(solve("days/14_input.txt")).to eq 888 }

  it { expect(solve_part_two("days/14_example.txt")).to eq 93 }
  it { expect(solve_part_two("days/14_input.txt")).to eq 26461 }
end
