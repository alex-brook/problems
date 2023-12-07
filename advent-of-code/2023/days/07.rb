require_relative "../spec_helper"

class DaySeven < Day
  KINDS = [[1,1,1,1,1], [1,1,1,2], [1,2,2], [1,1,3], [2,3], [1,4], [5]]

  def by_card(cards, ranks, wildcard)
    ->(a, b) {
      a_kind = kind(cards[a], wildcard)
      b_kind = kind(cards[b], wildcard)
      break a_kind <=> b_kind unless a_kind == b_kind

      5.times do |i|
        a_card = ranks.index(cards[a][i])
        b_card = ranks.index(cards[b][i])
        break a_card <=> b_card unless a_card == b_card

        0
      end
    }
  end

  def kind(hand, wildcard)
    @kind_cache ||= {}
    return @kind_cache[hand] if @kind_cache.key? hand

    tally = hand.chars.tally
    @kind_cache[hand] = 
      if wildcard && !(tally == { "J" => 5 })
        jokers = tally.delete("J") || 0
        best = tally.max_by { |_card, count| count }.first
        tally[best] += jokers
        KINDS.index(tally.values.sort)
      else
        KINDS.index(tally.values.sort)
      end
  end

  def parse_input(path)
    File
      .readlines(path, chomp: true)
      .map!(&:split)
      .transpose
  end

  def solve(path, ranks, wildcard)
    cards, bets = parse_input(path)

    sorter = by_card(cards, ranks, wildcard)
    is = (0...cards.size).sort(&sorter)

    is.each_with_index.reduce(0) do |acc, (i, j)|
      card = (j + 1) * bets[i].to_i
      acc + card
    end
  end

  def p1(path)
    ranks = %w[2 3 4 5 6 7 8 9 T J Q K A]
    solve(path, ranks, false)
  end

  def p2(path)
    ranks = %w[J 2 3 4 5 6 7 8 9 T Q K A]
    solve(path, ranks, true)
  end

  it { expect(p1("days/07_example.txt")).to eq(6440) }
  it { expect(p1("days/07_input.txt")).to eq(249748283) }

  it { expect(p2("days/07_example.txt")).to eq(5905) }
  it { expect(p2("days/07_input.txt")).to eq(248029057) }
end