require 'minitest/autorun'

module Chunks
  BRACKETS = {
    '{' => '}',
    '(' => ')',
    '[' => ']',
    '<' => '>'
  }.freeze

  POINTS = {
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25_137
  }.freeze

  INCOMPLETE_POINTS = POINTS.keys.zip(1..).to_h.freeze

  def score(filename)
    File
      .readlines(filename)
      .map(&:strip)
      .map { |line| check(line) }
      .filter { |code, _value| code != :incomplete }
      .sum(&:last)
  end

  def complete(filename)
    File
      .readlines(filename)
      .map(&:strip)
      .map { |line| check(line) }
      .filter { |(code, _value)| code == :incomplete }
      .map { |_code, stack| stack.reverse.map { |bracket| BRACKETS[bracket] } }
      .map { |brackets| brackets.reduce(0) { |acc, x| 5 * acc + INCOMPLETE_POINTS[x] } }
      .sort
      .then { |arr| arr[arr.length / 2] }
  end

  private

  def check(line, stack = [])
    return [:complete, true] if line.empty? && stack.empty? # was valid
    return [:incomplete, stack] if line.empty? # could be valid if input continued

    return check(line[1..], stack.push(line[0])) if BRACKETS.keys.include?(line[0])
    return check(line[1..], stack[0..-2]) if BRACKETS[stack.last] == line[0]

    [:corrupted, POINTS[line[0]]]
  end
end

class ChunksTest < Minitest::Test
  include Chunks

  def test_p1
    assert_equal 26_397, score('10/example.txt')
    assert_equal 345_441, score('10/input.txt')
  end

  def test_p2
    assert_equal 288_957, complete('10/example.txt')
    assert_equal 3_235_371_166, complete('10/input.txt')
  end
end
