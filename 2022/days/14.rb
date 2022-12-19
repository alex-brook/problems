require_relative "../spec_helper"

class DayFourteen < Day
  ROCK = "#"
  AIR = "."
  SAND = "o"

  def build(filename)
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
  end

  def draw(state)
    ((state[:lb_y] - 5)..state[:ub_y])
      .each do |y|
        (state[:lb_x]..state[:ub_x])
          .each do |x|
            print state[:map][[x,y]]
          end
        puts
      end
    puts "sand: #{state[:sand]}"
    puts
  end

  def fall(state, x=500, y=0)
    state[:map][[x,y]] = SAND
   # draw(state)
   # sleep 0.1 

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

  it { expect(solve("days/14_example.txt")).to eq 24 }
  it { expect(solve("days/14_input.txt")).to eq 888 }
end
