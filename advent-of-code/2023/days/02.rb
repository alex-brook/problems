require_relative "../spec_helper"

class DayTwo < Day
  PATTERNS = {
    /(\d+) red/ => 12,
    /(\d+) green/ => 13,
    /(\d+) blue/ => 14,
  }

  def p1(path)
    File
      .readlines(path, chomp: true)
      .each.with_index(1)
      .reduce(0) do |acc, (x, i)|
        possible = PATTERNS.all? do |pattern, max|
          x
            .scan(pattern)
            .flatten!
            .all? { |match| match.to_i <= max }
        end
        
        possible ? acc + i : acc
      end
  end

  def p2(path)
    File
      .readlines(path, chomp: true)
      .reduce(0) do |acc, x|
        power = PATTERNS.reduce(1) do |power, (pattern, _max)|
          color_max =
            x
              .scan(pattern)
              .flatten
              .map(&:to_i)
              .max

          power * color_max
        end

        acc + power
      end
  end

  it { expect(p1("days/02_example.txt")).to eq(8) }
  it { expect(p1("days/02_input.txt")).to eq(2727) }

  it { expect(p2("days/02_example.txt")).to eq(2286) }
  it { expect(p2("days/02_input.txt")).to eq(56580) }
end