require_relative "../spec_helper"

class DayThree < Day
  def read_parts(engine, pattern)
    parts = []
    engine.size.times do |i|
      j = 0
      loop do
        next_match = engine[i].match(pattern, j)
        break if next_match.nil?

        (j1, j2)= next_match.offset(0).dup
        j = j2
        parts << [i, j1, j2 - 1]
      end
    end
    parts
  end

  def p1(path)
    engine = File.readlines(path, chomp: true)
    numbers = read_parts(engine, /([0-9]+)/)
    
    numbers.filter do |(i, j1, j2)|
      found = false
      (i - 1..i + 1).each do |box_i|
        oob = box_i < 0 || box_i >= engine.size
        next if found || oob

        (j1 - 1..j2 + 1).each do |box_j|
          oob = box_j < 0 || box_j >= engine.first.size 
          is_num = i == box_i && (j1..j2).cover?(box_j)
          next if found || oob || is_num

          found = engine[box_i][box_j].match?(/[^\.]/)
        end
      end

      found
    end
    .sum { |(i, j1, j2)| engine[i][j1..j2].to_i }
  end

  def p2(path)
    engine = File.readlines(path, chomp: true)

    numbers =
      read_parts(engine, /([0-9]+)/)
      .group_by(&:first)
      .transform_values! { _1.map { |x| x[1]..x[2] } }

    read_parts(engine, /(\*)/)
      .reduce(0) do |acc, (i, j1, j2)|
        adjacent = []
        (i - 1..i + 1).each do |box_i|
          next if numbers[box_i].nil?

          adjacent += numbers[box_i].filter_map do |number|
            if (number.to_a & (j1 - 1.. j2 + 1).to_a).any? 
              [box_i, number.first, number.last]
            end
          end
        end
        
        next acc unless adjacent.size == 2
        
        acc + adjacent.reduce(1) do |adj_acc, (adj_i, adj_j1, adj_j2)|
          adj_acc * engine[adj_i][adj_j1..adj_j2].to_i
        end
      end
  end

  it { expect(p1("days/03_example_01.txt")).to eq(4361) }
  it { expect(p1("days/03_example_02.txt")).to eq(4361) }
  it { expect(p1("days/03_input.txt")).to eq(527364) }

  it { expect(p2("days/03_example_01.txt")).to eq(467835) }
  it { expect(p2("days/03_input.txt")).to eq(79026871) }
end