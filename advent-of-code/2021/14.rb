require "minitest/autorun"

module Polymer
  def solve(filename, n)
    template, rules = load(filename)

    step(template, rules, n)
  end

  def length_after_steps(filename, n)
    solve(filename, n).filter { |key, _v| key.length == 2 }.values.sum + 1
  end

  def count_after_steps(filename, char, n)
    solve(filename, n)[char]
  end

  def frequency_range(filename, n)
    solve(filename, n).filter { |key, _v| key.length == 1 }.minmax_by(&:last).reverse.map(&:last).reduce(&:-)
  end

  private

  def step(state, rules, n = 0)
    return state if n <= 0

    new_state = state
      .filter { |pair, _count| rules.key? pair } # {NN => 1, NC => 1, CB => 1}
      .flat_map do |pair, count| # [NC, 1], [CN, 1], [NB, 1], ...
      [
        [pair.chars.first + rules[pair], count],
        [rules[pair] + pair.chars.last, count],
        [rules[pair], count],
      ]
    end
      .reduce(state.reject { |pair, _count| rules.key? pair }) do |acc, (pair, count)|
      # [ ... , [AB, 5], [AB, 10], ...] => { AB => 15 }
      acc.update(pair => count) { |_pair, count_a, count_b| count_a + count_b }
    end

    step(
      new_state,
      rules,
      n - 1
    )
  end

  def load(filename)
    File
      .readlines(filename)
      .map(&:strip)
      .chunk_while { |i, j| !(i.empty? || j.empty?) }
      .to_a
      .then do |chunks|
      template = chunks.first.first.chars
      [
        template
          .each_cons(2)
          .map(&:join)
          .tally
          .merge(template.tally),
        chunks.last.to_h { |rule| rule.split(" -> ") },
      ]
    end
  end
end

class PolymerTest < Minitest::Test
  include Polymer

  def test_p1
    assert_equal 97, length_after_steps("14/example.txt", 5)
    assert_equal 3073, length_after_steps("14/example.txt", 10)
    assert_equal 1749, count_after_steps("14/example.txt", "B", 10)
    assert_equal 298, count_after_steps("14/example.txt", "C", 10)
    assert_equal 161, count_after_steps("14/example.txt", "H", 10)
    assert_equal 865, count_after_steps("14/example.txt", "N", 10)

    assert_equal 1588, frequency_range("14/example.txt", 10)
    assert_equal 3306, frequency_range("14/input.txt", 10)
  end

  def test_p2
    assert_equal 2192039569602, count_after_steps("14/example.txt", "B", 40)
    assert_equal 3849876073, count_after_steps("14/example.txt", "H", 40)
    assert_equal 2188189693529, frequency_range("14/example.txt", 40)

    assert_equal 3760312702877, frequency_range("14/input.txt", 40)
  end
end
