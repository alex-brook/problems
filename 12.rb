require "minitest/autorun"

module Caves
  def num_paths(filename)
    dfs(load(filename)) { |path, node| small_cave?(node) && path.include?(node) }.length
  end

  def num_extra_paths(filename)
    dfs(load(filename)) do |path, node|
      most_visited_small = path.filter { |cave| small_cave? cave }.uniq.map { |cave| path.count(cave) }.max || 0
      small_cave?(node) && path.count(node) > (most_visited_small == 2 ? 0 : 1)
    end
      .length
  end

  private

  def load(filename)
    File
      .readlines(filename)
      .map { |line| line.split("-").map(&:strip) }
      .then { |lines| lines + lines.map(&:reverse) }
      .group_by(&:first)
      .transform_values { |dest| dest.map(&:last).to_a }
  end

  def dfs(neighbours, current = "start", path = [], paths = [], &skip_fn)
    paths << (path + [current]) and return if current == "end"

    neighbours[current]&.each do |neighbour|
      next if neighbour == "start" || skip_fn.(path + [current], neighbour)

      dfs(neighbours, neighbour, path + [current], paths, &skip_fn)
    end
    path = nil
    return paths if current == "start"
  end

  def small_cave?(name)
    name.chars.all? { |c| c == c.downcase }
  end
end

class CavesTest < Minitest::Test
  include Caves

  def test_p1
    assert_equal 10, num_paths("12/example.txt")
    assert_equal 19, num_paths("12/large_example.txt")
    assert_equal 226, num_paths("12/larger_example.txt")
    assert_equal 5104, num_paths("12/input.txt")
  end

  def test_p2
    assert_equal 36, num_extra_paths("12/example.txt")
    assert_equal 103, num_extra_paths("12/large_example.txt")
    assert_equal 3509, num_extra_paths("12/larger_example.txt")
    assert_equal 149220, num_extra_paths("12/input.txt")
  end
end
