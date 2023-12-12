require_relative "../spec_helper"

class DayTwelve < Day

  State = Struct.new(:line, :i, :groups, :moves) do
    def choice?
      self.line[self.i] == "?"
    end

    def move(cell=nil, &blk)
      self.line[self.i] = cell unless cell.nil?

      prev = self.i == 0 ? "." : self.line[self.i - 1] 
      cur = self.line[self.i]
      created_group = prev == "." && cur == "#"
      extended_group = prev == "#" && cur == "#"

      self.groups.push(1) if created_group
      self.groups[-1] += 1 if extended_group

      self.i += 1
      yield
      self.i -= 1

      self.groups.pop if created_group
      self.groups[-1] -= 1 if extended_group

      self.line[self.i] = "?" unless cell.nil?
    end

    def reset(line)
      self.i = 0
      self.groups = []
      self.line = line
    end
  end

  def walk(state, constraint)
    memoized = @memo[[state.line[state.i - 1], state.line.size - state.i, state.groups]]
    return memoized if memoized

    completed_groups = state.groups.size - 1

    invalid = (state.groups.size > constraint.size) ||
              (completed_groups > 0 && completed_groups.times.any? { state.groups[_1] != constraint[_1] } ) ||
              (completed_groups >= 0 && state.groups.last > constraint[completed_groups]) ||
              (state.i >= state.line.size && !(state.groups.size == constraint.size && state.groups.last == constraint.last)) 

    solutions = 0
    if invalid
      solutions = 0
    elsif state.i >= state.line.size
      solutions = 1
    elsif state.choice?
      state.move(".") do
        solutions += walk(state, constraint)
      end

      state.move("#") do
        solutions += walk(state, constraint)
      end
    else
      state.move do
        solutions += walk(state, constraint)
      end
    end

    @memo[[state.line[state.i - 1], state.line.size - state.i, state.groups.dup]] = solutions
  end

  def parse_input(path)
    File
      .readlines(path, chomp: true)
      .map! { [_1.split.first, _1.scan(/\d+/).map(&:to_i)] }
  end

  def p1(path)
    state = State.new
    lines = parse_input(path)

    lines
      .sum do |(line, constraint)|
        @memo = {}
        state.reset(line)
        walk(state, constraint)
      end
  end

  def p2(path)
    state = State.new
    lines = parse_input(path)

    lines
      .map! do |(line, constraint)|
        [([line] * 5).join("?"), constraint * 5]
      end
      .sum do |(line, constraint)|
        @memo = {}
        state.reset(line)
        walk(state, constraint)
      end
  end

  it { expect(p1("days/12_example.txt")).to eq(21) }
  it { expect(p1("days/12_input.txt")).to eq(7633) }

  it { expect(p2("days/12_example.txt")).to eq(525152) }
  it { expect(p2("days/12_input.txt")).to eq(23903579139437) }
end