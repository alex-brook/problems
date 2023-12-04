require_relative "../spec_helper"

class DayFour < Day
  def process(path)
    i = -1
    File
      .readlines(path, chomp: true)
      .reduce([0, {}]) do |(acc, copies), line|
        i += 1
        copies[i] ||= 1

        line = line
          .gsub!(/Card\s+\d+: /, "")
          .scan(/\d+|\|/)

        winners = []
        winners << line.shift until line.first == "|"
        line.shift

        matches = line.reduce(0) do |matches, x|
          if winners.include?(x)
            matches + 1
          else
            matches
          end 
        end

        next [acc, copies] if matches.zero?
        (1..matches).each do |j|
          multiplier = copies[i]
          copies[i + j] = (copies[i + j] || 1) + multiplier
        end

        [acc + (2 ** (matches - 1)), copies]
      end
  end

  def p1(...)
    acc, _copies = process(...)
    acc
  end

  def p2(...)
    _acc, copies = process(...)
    copies.values.sum
  end

  it { expect(p1("days/04_example.txt")).to eq(13) }
  it { expect(p1("days/04_input.txt")).to eq(25174) }

  it { expect(p2("days/04_example.txt")).to eq(30) }
  it { expect(p2("days/04_input.txt")).to eq(6420979) }
end