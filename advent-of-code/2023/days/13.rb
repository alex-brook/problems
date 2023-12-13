require_relative "../spec_helper"

class DayThirteen < Day

  def fold(len, after)
    Enumerator.new do |y|
      left = after
      right = after + 1
      while left >= 0 && right < len
        y << [left, right]
        left -= 1
        right += 1
      end
    end
  end

  def reflect(pattern, target=0)
    row_len = pattern.first.size
    (0...pattern.size - 1).each do |i|
      next false if fold(pattern.size, i).none?

      errors = 0
      fold(pattern.size, i).each do |a, b|
        (0...row_len).each do |j|
          errors += 1 unless pattern[a][j] == pattern[b][j]
        end
      end

      return i if errors == target
    end

    nil
  end

  def parse_input(path)
    File
      .readlines(path, chomp: true)
      .reduce([[]])  { |acc, x| x == "" ? acc.push([]) : acc.last.push(x.split("")) ; acc }
  end

  def p1(path)
    parse_input(path).sum do |pattern|
      if x = reflect(pattern)
        x += 1
        x *= 100
      elsif x = reflect(pattern.transpose)
        x += 1
      end
    end
  end


  def p2(path)
    parse_input(path).sum do |pattern|
      flipped = false
      idx = reflect(pattern, 1) || flipped = true && reflect(pattern.transpose, 1)
      idx += 1
      idx *= 100 unless flipped

      idx
    end
  end

  it { expect(p1("days/13_example.txt")).to eq(405) } 
  it { expect(p1("days/13_input.txt")).to eq(32723) } 

  it { expect(p2("days/13_example.txt")).to eq(400) }
  it { expect(p2("days/13_input.txt")).to eq(34536) } 
end