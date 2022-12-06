require_relative "../spec_helper"

class DayFive < Day
  def solve(filename, crane=false)
    File
      .readlines(filename, chomp: true)
      .chunk_while { |before, after| !after.empty? }
      .to_a
      .then do |((*stack_slices, _ignored), (_ignored, *instructions))|
        stacks = stack_slices
          # break the slices into lists of characters
          .map do |stack_slice|
            stack_slice 
              .gsub(/    /, "-")
              .tr("[] ", "")
              .chars
          end
          .transpose
          .map { |stack| stack.filter { _1 != "-" } }
          .map(&:reverse)

          # apply the instructions
          instructions.reduce(stacks) do |acc, instruction|
            /move (\d+) from (\d+) to (\d+)/
              .match(instruction)
              .captures
              .map(&:to_i) in [amount, from, to]

            acc[to - 1].push(
              *acc[from - 1]
                .pop(amount)
                .then { crane ? _1 : _1.reverse }
            )
            acc
          end
          .map(&:pop)
          .join
      end
  end

  it { expect(solve("days/5_example.txt")).to eq "CMZ" }
  it { expect(solve("days/5_input.txt")).to eq "FWSHSPJWM" }

  it { expect(solve("days/5_example.txt", true)).to eq "MCD" }
  it { expect(solve("days/5_input.txt", true)).to eq "PWPWHGFZS" }
end
