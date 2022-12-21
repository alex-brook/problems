require_relative "../spec_helper"
require "set"

class DayFifteen < Day
  BEACON = "B"
  SENSOR = "S"
  GROUND = "."

  def distance(x1, y1, x2, y2)
    [x1 - x2, y1 - y2].map(&:abs).sum
  end

  def width(sy, r, y)
    [0, r - (sy - y).abs].max
  end

  def read(filename)
    File
      .read(filename)
      .scan(/[\-\d]+/)
      .map(&:to_i)
      .each_slice(4)
      .reduce([[], Set.new]) do |(circles, beacons), (sx, sy, bx, by)|
        beacons.add([bx, by])
        circles << [sx, sy, distance(sx, sy, bx, by)]
        
        [circles, beacons]
      end
  end

  def solve(filename, target_row=10)
    circles, beacons = read(filename)

    circles
      .filter_map do |(sx, sy, r)|
        w = width(sy, r, target_row)
        range = (sx - w)..(sx + w)
        xs = range.filter { !beacons.include?([_1, target_row]) } if w > 0
      end
      .flatten
      .uniq
      .size
  end

  def join_ranges(range_1, range_2)
    [range_1, range_2].sort_by(&:first) in [range_1, range_2]

    potential_gap = (range_1.last + 1)...range_2.first

    if potential_gap.none?
      [:joined, range_1.first..[range_1.last, range_2.last].max]
    else
      [:gap, potential_gap] 
    end
  end

  def solve_part_two(filename, x_ub=Float::INFINITY, y_ub=Float::INFINITY)
    circles, _beacons = read(filename)

    constraints = Hash.new { Array.new } 

    (0..y_ub).reverse_each do |y|
      res = circles
        .filter_map do |(sx, sy, r)|
          w = width(sy, r, y)
          (sx - w)..(sx + w) if w > 0
        end
        .sort_by(&:first)
        .reduce do |acc, range|
          case join_ranges(acc, range)
            in [:joined, new_range]
              new_range
            in [:gap, new_range]
              break [:found, [new_range.first, y]]
          end
        end

        if res in [:found, coords]
          break coords
        end
    end
    .then { |x, y| x * 4_000_000 + y }
  end

  it { expect(solve("days/15_example.txt")).to eq 26 }
  it { expect(solve("days/15_input.txt", 2_000_000)).to eq 5525847 }
  
  it { expect(solve_part_two("days/15_example.txt", 20, 20)).to eq 56000011 }
  it { expect(solve_part_two("days/15_input.txt", 4_000_000, 4_000_000)).to eq 13340867187704 }
end
