require_relative "../spec_helper"
require "set"
class DayFive < Day
  def parse_input(path)
    f = File.read(path)
    seeds_sep = f.index("\n")
    seeds = f[0...seeds_sep].scan(/\d+/).map!(&:to_i)
    stages = f[seeds_sep + 1...]
      .split("\n\n")
      .map! { _1.scan(/\d+/).map!(&:to_i).each_slice(3).to_a }

    [seeds, stages]
  end

  # chunk the query range depending on which parts matched
  def partition(q0, ql, r0, rl)
    mid0 = [q0, r0].max
    midl = [q0 + ql, r0 + rl].min - mid0

    # there is no intersection, the query is unaffected
    return nil unless midl.positive?

    partitions = [[mid0, midl]]

    # does the query overhang the left of the range?
    if q0 < mid0
      left0 = q0
      leftl = mid0 - q0
      partitions.unshift([left0, leftl]) if leftl.positive?
    else
      partitions.unshift nil
    end

    # does the query overhang the right of the range?
    if q0 + ql > mid0 + midl
      right0 = mid0 + midl
      rightl = right0 - q0
      partitions.push([right0, rightl]) if rightl.positive?
    else
      partitions.push nil
    end

    partitions
  end

  # given a query range, apply the mapping and return the resulting ranges
  def apply_range(q0, ql, rd, r0, rl)
    result = partition(q0, ql, r0, rl)
    return if result.nil?

    result => [left, [m0, ml], right]
    offset = rd - r0
    m0 += offset
    [left, [m0, ml], right].compact
  end

  # given a pool of query ranges and a pool of filters,
  # apply all mappings and consolidate & sort the results
  def apply_stage(queries, stage)
    result = []
    queries.each do |(q0, ql)|
      matched = false
      stage.each do |(rd, r0, rl)|
        application = apply_range(q0, ql, rd, r0, rl)

        if application
          result += application
          matched = true
        end
      end
      result.push [q0, ql] unless matched
    end
    result.uniq!
    result.sort!
    result.drop_while { |(start, len)| start == 0 }
  end

  def apply_stages(queries, stages)
    return queries if stages.none?

    queries = apply_stage(queries, stages.first)
    stages.shift
    apply_stages(queries, stages)
  end 

  def p1(path)
    seeds, stages = parse_input(path)
    seeds.map! { [_1, 1] }
    apply_stages(seeds, stages).first.first
  end

  def p2(path)
    seeds, stages = parse_input(path)
    seeds = seeds.each_slice(2).to_a
    apply_stages(seeds, stages).first.first
  end

  it { expect(partition(1, 10, 100, 10)).to eq(nil) } # query well clear on lhs
  it { expect(partition(100, 10, 1, 10)).to eq(nil) } # query well clear on rhs
  it { expect(partition(5, 5, 0, 10)).to eq([nil, [5,5], nil]) } # range completely covers query
  it { expect(partition(0, 10, 2, 3)).to eq([[0,2], [2,3], [5,5]]) } # query completely covers range
  it { expect(partition(0, 4, 2, 4)).to eq([[0,2], [2,2], nil]) } # query overhangs the left of range
  it { expect(partition(2, 4, 0, 4)).to eq([nil, [2,2], [4,2]])} # query overhangs to the right of range

  it { expect(apply_range(79, 1, 50, 98, 2)).to eq(nil) }
  it { expect(apply_range(79, 1, 52, 50, 48)).to eq([[81, 1]]) }
  it { expect(apply_range(14, 1, 50, 98, 2)).to eq(nil) }
  it { expect(apply_range(14, 1, 52, 50, 48)).to eq(nil) }
  it { expect(apply_range(55, 1, 50, 98, 2)).to eq(nil) }
  it { expect(apply_range(55, 1, 52, 50, 48)).to eq([[57, 1]]) }
  it { expect(apply_range(13, 1, 50, 98, 2)).to eq(nil) }
  it { expect(apply_range(13, 1, 52, 50, 48)).to eq(nil) }

  it "returns the correct seed-to-soil for the example" do
    seeds, stages = parse_input("days/05_example.txt")
    seeds.map! { [_1, 1] }
    expect(apply_stages(seeds, stages[...1])).to eq([[13, 1], [14, 1], [57, 1], [81, 1]])
  end

  it "returns the correct seed-to-fertilizer for the example" do
    seeds, stages = parse_input("days/05_example.txt")
    seeds.map! { [_1, 1] }
    expect(apply_stages(seeds, stages[...2])).to eq([[52, 1], [53, 1], [57, 1], [81, 1]])
  end

  it "returns the correct seed-to-fertilizer for the example" do
    seeds, stages = parse_input("days/05_example.txt")
    seeds.map! { [_1, 1] }
    expect(apply_stages(seeds, stages)).to eq([[35, 1], [43, 1], [82, 1], [86, 1]])
  end

  it { expect(p1("days/05_example.txt")).to eq(35) }
  it { expect(p1("days/05_input.txt")).to eq(650599855) }

  it { expect(p2("days/05_example.txt")).to eq(46) }
  it { expect(p2("days/05_input.txt")).to eq(1240035) }
end