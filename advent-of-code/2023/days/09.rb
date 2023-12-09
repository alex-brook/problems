require_relative "../spec_helper"

class DayNine < Day
  def down(nums)
    return (nums.last || 0) if nums.none? || nums.all?(&:zero?)

    nums2 = (0..nums.size - 2).map do |i|
      (nums[i] - nums[i + 1]).abs
      nums[i + 1] - nums[i]
    end

    s = down(nums2) + nums.last
    s
  end

  def p1(path)
    File
      .readlines(path, chomp: true)
      .map!{ _1.split(" ").map!(&:to_i) } 
      .sum { down(_1) }
  end

  def p2(path)
    File
      .readlines(path, chomp: true)
      .map!{ _1.split(" ").map!(&:to_i).reverse! } 
      .sum { down(_1) }
  end

  it { expect(p1("days/09_example.txt")).to eq(114) }
  it { expect(p1("days/09_input.txt")).to eq(1725987467) }

  it { expect(p2("days/09_example.txt")).to eq(2) }
  it { expect(p2("days/09_input.txt")).to eq(971) }
end