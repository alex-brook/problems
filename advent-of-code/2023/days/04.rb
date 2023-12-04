require_relative "../spec_helper"

class DayFour < Day
  def process(path)
    i = -1
    copies = {}
    File
      .readlines(path, chomp: true)
      .reduce([0, 0]) do |(acc, count), line|
        i += 1
        copies[i] ||= 1

        line = line
          .gsub!(/Card\s+\d+: /, "")
          .scan(/\d+|\|/)

        winners = []
        winners << line.shift until line.first == "|"
        line.shift

        matches = line.count { winners.include? _1 }

        next [acc, count + copies[i]] if matches.zero?

        matches.times { |j| copies[i + j + 1] = (copies[i + j + 1] || 1) + copies[i] }

        [acc + (2 ** (matches - 1)), count + copies[i]]
      end
  end

  def p1(...)
    acc, _copies = process(...)
    acc
  end

  def p2(...)
    _acc, copies = process(...)
    copies
  end

  it { expect(p1("days/04_example.txt")).to eq(13) }
  it { expect(p1("days/04_input.txt")).to eq(25174) }

  it { expect(p2("days/04_example.txt")).to eq(30) }
  it { expect(p2("days/04_input.txt")).to eq(6420979) }
end