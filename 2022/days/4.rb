require_relative "../spec_helper"

class DayFour < Day
  cover = ->(lb, ub, *points) { points.all? { _1 >= lb && _1 <= ub } }
  overlap = ->(lb, ub, *points) { points.any? { _1 >= lb && _1 <= ub} }

  def solve(filename, &f)
    File
      .foreach(filename)
      .map { _1.strip.split(/,|-/).map(&:to_i) }
      .count { |(a_lb, a_ub, b_lb, b_ub)| f.call(b_lb, b_ub, a_lb, a_ub) || f.call(a_lb, a_ub, b_lb, b_ub) }
  end

  it { expect(solve("days/4_example.txt", &cover)).to eq 2 }
  it { expect(solve("days/4_input.txt", &cover)).to eq 580 }

  it { expect(solve("days/4_example.txt", &overlap)).to eq 4 }
  it { expect(solve("days/4_input.txt", &overlap)).to eq 895 }
end
