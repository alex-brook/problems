require_relative "../spec_helper"

class DaySix < Day
  def solve(t, d)
    d += 1 # to beat it
    sqrt_part = Math.sqrt((t ** 2) - 4 * d)

    [(t + sqrt_part).fdiv(2.0).floor, (t - sqrt_part).fdiv(2.0).ceil]
  end

  def p1(path)
    File
      .readlines(path, chomp: true)
      .map! { _1.scan(/\d+/).map!(&:to_i) } => [ts, ds]

    (0...ts.size).map { solve(ts[_1], ds[_1]).reduce(&:-) + 1 }.reduce(&:*)
  end

  def p2(path)
    File
      .readlines(path, chomp: true)
      .map! { _1.scan(/\d+/).reduce(&:+).to_i } => [t, d]

    solve(t, d).reduce(&:-) + 1 
  end

  it { expect(p1("days/06_example.txt")).to eq(288) }
  it { expect(p1("days/06_input.txt")).to eq(5133600) }

  it { expect(p2("days/06_example.txt")).to eq(71503) }
  it { expect(p2("days/06_input.txt")).to eq(40651271) }
end 