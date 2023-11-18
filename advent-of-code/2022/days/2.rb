require_relative "../spec_helper"

class DayTwo < Day
  def solve(filename, mode=1)
    move = {
      "A" => 1,
      "X" => 1,
      "B" => 2,
      "Y" => 2,
      "C" => 3,
      "Z" => 3
    }

    beats = {
      3 => 1,
      1 => 2,
      2 => 3
    }

    round_score = if mode == 1
        ->((them, me)) {
          if move[me] == move[them]
            3 # draw
          elsif beats[move[them]] == move[me]
            6 # win
          else
            0 # loss
          end + move[me]
        }
      elsif mode == 2
        ->((them, me)) {
          if me == "X"
            beats[beats[move[them]]]
          elsif me == "Y"
            3 + move[them]
          else
            6 + beats[move[them]]
          end
        }
      end

    File
      .foreach(filename)
      .map(&:split)
      .sum(&round_score)
  end
  
  # part one
  it { expect(solve("days/2_example.txt")).to eq 15 }
  it { expect(solve("days/2_input.txt")).to eq 12276 }

  # part two
  it { expect(solve("days/2_example.txt", 2)).to eq 12 }
  it { expect(solve("days/2_input.txt", 2)).to eq 9975 }
end
