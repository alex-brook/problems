require_relative "../spec_helper"

require "set"

class DayNineteen < Day
  class Node
    attr_reader :line

    def initialize(line)
      @line = line
      @tokens = tokenize(line)
      @token = 0
    end

    def to_s
      "<#{self.class.name} #{@line}>"
    end

    private

    def take(*expected_tokens)
      actual_token = @tokens[@token].respond_to?(:each) ? @tokens[@token].first : @tokens[@token]

      if expected_tokens.include?(actual_token)
        @token += 1
        @tokens[@token - 1]
      else
        raise "Syntax Error: expected one of #{expected_tokens} but got #{actual_token}"
      end
    end

    def peek(n=0)
      @tokens[@token + n]
    end 

    def tokenize(line)
      tokens = []
      i = 0
      while i < line.size
        tokens <<
          case line[i]
          in "{" then :left_brace
          in "}" then :right_brace
          in "<" then :greater_than
          in ">" then :less_than
          in "=" then :equals
          in ":" then :colon
          in "," then :comma
          in /[a-z]/i
            identifier = ""
            identifier << line[i] and i += 1 while i < line.size && line[i].match?(/[a-z]/i)
            i -= 1
            [:identifier, identifier]
          in /[0-9]/
            number = ""
            number << line[i] and i += 1 while i < line.size && line[i].match?(/[0-9]/)
            i -= 1
            [:number, number.to_i]
          end

          i += 1
      end

      tokens
    end
  end

  class Rule < Node
    @@rules = {
      "A" => :accept,
      "R" => :reject,
    }

    def self.[](label)
      @@rules[label]
    end

    attr_reader :label, :conditions, :fallback, :variables

    def initialize(line)
      super
      @conditions = []
      parse
      @@rules[label] = self
    end

    # given a set of ranges return a list of pairs of
    # next ranges and next rules
    def map_ranges(ranges)
      dup_ranges = ->(r) { r.dup.transform_values(&:dup) }
      next_pairs = []

      # for each condition, it can either be true or false.
      false_ranges = dup_ranges[ranges]
      conditions.each do |(var, opcode, operand, ret)|
        true_ranges = dup_ranges[false_ranges]
        if opcode == :greater_than
          true_ranges[var][1] = [true_ranges[var][1], operand - 1].min
          false_ranges[var][0] = [false_ranges[var][0], operand].max
        elsif opcode == :less_than
          true_ranges[var][0] = [true_ranges[var][0], operand + 1].max
          false_ranges[var][1] = [false_ranges[var][1], operand].min
        end

        next_pairs.push([Rule[ret], true_ranges])
      end
      next_pairs.push([Rule[fallback], false_ranges])
      next_pairs
    end

    def parse
      @label = take(:identifier).last
      take(:left_brace)
      loop do
        take_condition
        
        break if peek(2) == :right_brace
        take(:comma)
      end
      take(:comma)
      @fallback = take(:identifier).last
      take(:right_brace)
    end

    def take_condition
      var = take(:identifier).last
      opcode = take(:greater_than, :less_than)
      operand = take(:number).last
      take(:colon)
      result = take(:identifier).last

      @conditions << [var, opcode, operand, result]
    end
  end

  class Query < Node
    attr_reader :history

    def initialize(line)
      super
      @attributes = {}
      parse
    end

    def accepted?(accepted)
      accepted.any? do |ranges|
        ranges.all? do |var, (lb, ub)|
          @attributes[var] >= lb && @attributes[var] <= ub
        end
      end 
    end

    def total
      @attributes.values.sum
    end

    def [](label)
      @attributes[label]
    end

    def parse
      take(:left_brace)
      loop do
        attribute = take(:identifier).last
        take(:equals)
        value = take(:number).last

        @attributes[attribute] = value
        break unless peek == :comma
        take(:comma)
      end
      take(:right_brace)
    end
  end

  def parse_input(path)
    File
      .read(path, chomp: true)
      .split("\n\n")
      .map! { _1.split("\n") }
  end

  def process
    start_rule = Rule["in"]
    start_ranges = { "x" => [1, 4000], "m" => [1, 4000], "a" => [1, 4000], "s" => [1, 4000]}

    accepted_ranges = []

    # bfs to find all possible ranges
    rules = [start_rule]
    ranges = [start_ranges]
    while rules.any?
      current_rule = rules.shift
      current_ranges = ranges.shift

      current_rule.map_ranges(current_ranges).each do |(next_rule, next_ranges)|
        if next_rule == :reject
          next
        elsif next_rule == :accept
          accepted_ranges.push(next_ranges)
          next
        end

        rules.push(next_rule)
        ranges.push(next_ranges)
      end
    end

    accepted_ranges
  end

  def p1(path)
    rules, queries = parse_input(path)

    rules.map! { Rule.new(_1) }
    queries.map! { Query.new(_1) }
    accepted = process

    queries.sum do |query|
      if query.accepted?(accepted)
        query.total
      else
        0
      end
    end
  end

  def p2(path)
    rules, queries = parse_input(path)
    rules.map! { Rule.new(_1) }
    queries.map! { Query.new(_1) }
    accepted = process

    accepted.sum do |ranges|
      ranges.values.reduce(1) do |acc, (lb, ub)|
        acc * (ub - lb + 1)
      end
    end
  end

  it { expect(p1("days/19_example.txt")).to eq(19114) }
  it { expect(p1("days/19_input.txt")).to eq(331208) }

  it { expect(p2("days/19_example.txt")).to eq(167409079868000) }
  it { expect(p2("days/19_input.txt")).to eq(121464316215623) }
end