require_relative "../spec_helper"

class DayFifteen < Day

  require "set"

  Lens = Struct.new(:str, :label, :op, :val) do
    def initialize(str)
      label, op, val = str.partition(/=|-/)
      self.label = label
      self.op = op
      self.val = val unless val.empty?
    end

    def inspect
      "<label=#{label}  val=#{val}>"
    end

    def hash()= HASH(self.label)

    def hash_all()= HASH(self.label + self.op + (self.val || ""))

    def put?()= self.op == "="

    private

    def HASH(str)= str.chars.reduce(0) { |acc, c| ((acc + c.ord) * 17) % 256 }
  end

  def parse_input(path)
    File
      .read(path)
      .strip
      .split(",")
  end

  def p1(path)
    parse_input(path).sum { Lens.new(_1).hash_all }
  end

  def p2(path)
    lenses = {}
    parse_input(path).each do |lens|
      lens = Lens.new(lens)
      
      lenses[lens.hash] ||= []
      existing = lenses[lens.hash].index { _1.label == lens.label }
      if lens.put? && existing
        lenses.dig(lens.hash, existing).val = lens.val
      elsif lens.put?
        lenses[lens.hash].push lens
      else
        lenses[lens.hash].delete_if { |x| x.label == lens.label }
      end
    end
    lenses.flat_map do |(hash, ls)|
      ls.each_with_index.map do |lens, i|
        (1 + hash) * (1 + i) * lens.val.to_i
      end
    end
    .sum
  end

  it { expect(p1("days/15_example.txt")).to eq(1320) }
  it { expect(p1("days/15_input.txt")).to eq(503487) }

  it { expect(p2("days/15_example.txt")).to eq(145) }
  it { expect(p2("days/15_input.txt")).to eq(261505) }
end