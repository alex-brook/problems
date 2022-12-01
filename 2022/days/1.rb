require_relative "../spec_helper.rb"

class DayOne < Day
  def solve(filename, n=1)
    File
      .foreach(filename)
      .chunk_while { _1 != "\n" }
      .map { _1.sum(&:to_i) }
      .max(n)
      .sum
  end

  # part one
  it { expect(solve("days/1_example.txt")).to eq 24000 }
  it { expect(solve("days/1_input.txt")).to eq 72602 }

  # part two
  it { expect(solve("days/1_example.txt", 3)).to eq 45000 }
  it { expect(solve("days/1_input.txt", 3)).to eq 207410 }
end
