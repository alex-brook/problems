require_relative "../spec_helper"

class DayOne < Day
  def p1(path)
    File
      .readlines(path, chomp: true)
      .reduce(0) do |acc, x|
        x.gsub!(/[[:alpha:]]/, "")
        acc + (x[0] + x[-1]).to_i
      end
  end

  def p2(path)
    digits = %w[one two three four five six seven eight nine]
    pattern = /(#{digits.join("|")}|[\d])/

    File
      .readlines(path, chomp: true)
      .reduce(0) do |acc, x|
        x.index(pattern)
        first_digit = $~[0]
        x.rindex(pattern)
        second_digit = $~[0]

        fdi = digits.index(first_digit)
        sdi = digits.index(second_digit)
        first_digit = (fdi + 1).to_s unless fdi.nil?
        second_digit = (sdi + 1).to_s unless sdi.nil?
        val = (first_digit + second_digit).to_i

        acc + val
      end
  end

  it { expect(p1("days/01_example_01.txt")).to eq(142) }
  it { expect(p1("days/01_input.txt")).to eq(55477) }

  it { expect(p2("days/01_example_02.txt")).to eq(281) }
  it { expect(p2("days/01_input.txt")).to eq(54431) }
end