require_relative "../spec_helper"
require "set"

class DaySix < Day
  def solve(data, n=4)
    data
      .chars
      .each_cons(n)
      .find_index { Set.new(_1).size == n } + n
  end

  it { expect(solve("bvwbjplbgvbhsrlpgdmjqwftvncz")).to eq 5 }
  it { expect(solve("nppdvjthqldpwncqszvftbrmjlhg")).to eq 6 }
  it { expect(solve("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg")).to eq 10 }
  it { expect(solve("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw")).to eq 11 }

  it { expect(solve(File.read("days/6_input.txt"))).to eq 1892 }
  it { expect(solve(File.read("days/6_input.txt"), 14)).to eq 2313 }
end
