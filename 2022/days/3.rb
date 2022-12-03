require_relative "../spec_helper"

class DayThree < Day
  def priorities
    (("a".."z").to_a + ("A".."Z").to_a)
      .each
      .with_index
      .to_h { |key, value| [key, value + 1] }
  end

  def solve(filename)
    priority = priorities

    File
      .foreach(filename)
      .sum do |bag|
        characters = bag.chars
        first_half = characters[...bag.size / 2] 
        second_half = characters[bag.size / 2..]
        first_half.intersection(second_half).sum { priority[_1] }
      end
  end

  def solve_part_two(filename, group)
    priority = priorities

    File
      .foreach(filename)
      .each_slice(group)
      .sum do |group|
        priority[
          group
            .map { _1.chars[...-1] }
            .reduce(&:intersection)
            .first
        ]
      end
  end

  it { expect(solve("days/3_example.txt")).to eq 157 }
  it { expect(solve("days/3_input.txt")).to eq 8085 }

  it { expect(solve_part_two("days/3_example.txt", 3)).to eq 70 }
  it { expect(solve_part_two("days/3_input.txt", 3)).to eq 0 }
end
