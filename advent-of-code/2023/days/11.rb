require_relative "../spec_helper"

class DayEleven < Day
  def solve(path, warp=2)
    warp -= 1

    rc = File
      .readlines(path, chomp: true)
      .map! { _1.split("") }

    cr = rc.transpose

    empty_rows = (0...rc.size).filter { |i| rc[i].none?("#") }
    empty_cols = (0...cr.size).filter { |i| cr[i].none?("#") }
    galaxies = []
    (0...rc.size).each do |i|
      (0...rc[i].size).each do |j|
        galaxies.push([i, j]) if rc.dig(i, j) == "#"
      end
    end
    galaxies
      .combination(2)
      .sum do |(ay, ax), (by, bx)|
        m = (ay - by).fdiv(ax - bx)
        c = ay - m * ax

        interceptions = 0
        empty_cols.each do |x|
          next unless x >= [ax, bx].min && x <= [ax, bx].max

          intercept = m * x + c
          if intercept >= [ay, by].min && intercept <= [ay, by].max 
            interceptions += 1
          end
        end
        empty_rows.each do |y|
          next unless y >= [ay, by].min && y <= [ay, by].max

          intercept = (y - c).fdiv(m)
          if m.infinite? || intercept >= [ax, bx].min && intercept <= [ax, bx].max
            interceptions += 1
          end
        end

        distance = (ay - by).abs + (ax - bx).abs

        distance + (interceptions * warp) 
      end
  end

  it { expect(solve("days/11_example.txt")).to eq(374) }
  it { expect(solve("days/11_input.txt")).to eq(9609130) }

  it { expect(solve("days/11_example.txt", 10)).to eq(1030) }
  it { expect(solve("days/11_example.txt", 100)).to eq(8410) }
  it { expect(solve("days/11_input.txt", 1_000_000)).to eq(702152204842) }
end