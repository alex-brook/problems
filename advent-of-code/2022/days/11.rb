require_relative "../spec_helper"

class DayEleven < Day
  def string_to_id(string)
    /Monkey (\d+)/
      .match(string)
      .captures
      .first
      .to_i
  end

  def string_to_items(string)
    /Starting items: ([, \d]+)\n/
      .match(string)
      .captures
      .first
      .split(", ")
      .map(&:to_i)
      .reverse
  end

  def string_to_test(string)
    /divisible by (\d+)/
      .match(string)
      .captures
      .first
      .to_i
  end

  def string_to_operation(string)
    arg1, operator, arg2 = /new = (old|\d+) ([*+]) (old|\d+)/
      .match(string)
      .captures

    ->(old) {
      a1 = (arg1 == "old" ? old : arg1.to_i)
      a2 = (arg2 == "old" ? old : arg2.to_i)

      case operator
        in "+"
          a1 + a2
        in "*"
          a1 * a2
      end
    }
  end

  def string_to_targets(string)
    true_monkey, false_monkey = string
      .scan(/throw to monkey (\d+)+/)
      .flatten
      .map(&:to_i)

    { true => true_monkey, false => false_monkey }
  end

  Monkey = Struct.new(
    :id,
    :items,
    :test,
    :operation,
    :targets,
    :inspections
  )

  def solve(filename, rounds=20, part=:one)
    monkeys = File
      .read(filename)
      .split("\n\n")
      .map do |string|
        Monkey.new(
          string_to_id(string),
          string_to_items(string),
          string_to_test(string),
          string_to_operation(string),
          string_to_targets(string),
          0
        )
      end

    n = monkeys.map(&:test).reduce(&:*)

    rounds.times do 
      monkeys.each do |monkey|
        until monkey.items.empty?
          item = monkey.items.pop

          updated_item = monkey
            .operation
            .call(item)
            .then do |item|
              if part == :one
                item / 3
              elsif part == :two
                item % n
              end
            end

          monkey.inspections += 1


          target_i = updated_item % monkey.test == 0
          target = monkeys.find { _1.id == monkey.targets[target_i] } 
          target.items.push(updated_item)
        end
      end
    end

    monkeys.map(&:inspections).max(2).reduce(&:*)
  end

  it { expect(solve("days/11_example.txt", 20, :one)).to eq 10605 }
  it { expect(solve("days/11_input.txt", 20, :one)).to eq 99852 }

  it { expect(solve("days/11_example.txt", 10000, :two)).to eq 2713310158 }
  it { expect(solve("days/11_input.txt", 10000, :two)).to eq 25935263541 }
end
