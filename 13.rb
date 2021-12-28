require "minitest/autorun"
require "set"
require "matrix"

module Origami
  def solve_first(filename)
    dots, folds = load(filename)
    result = fold(paper(dots), folds.first)
    count_dots(result)
  end

  def solve(filename)
    dots, folds = load(filename)
    result = folds.reduce(paper(dots)) { |paper, fold| fold(paper, fold) }
    print_paper(result)
  end

  private

  def count_dots(paper)
    paper.sum { |e| e ? 1 : 0 }
  end

  def load(filename)
    File
      .readlines(filename)
      .map(&:strip)
      .chunk_while { |i, j| !(i.empty? || j.empty?) }
      .to_a
      .then do |input|
      [
        input.first.map { |dot| dot.split(",").map(&:to_i) },
        input.last.map { |fold| fold.split(" ").last.split("=").then { |fold| [fold.first, fold.last.to_i] } },
      ]
    end
  end

  def paper(dots)
    x = dots.flat_map(&:first).max + 1
    y = dots.flat_map(&:last).max + 1
    dot_set = dots.to_set

    Matrix.build(y, x) { |row, col| dot_set.include? [col, row] }
  end

  def print_paper(paper)
    paper.row_vectors.each.with_object("") do |row, buf|
      buf << row.each.map { |place| place ? "#" : "." }.join << "\n"
    end
  end

  def fold(paper, fold)
    direction, amount = fold

    case direction
    when "x"
      foldee = paper.minor(0..-1, 0...amount)
      folded = Matrix.columns(paper.minor(0..-1, amount + 1..-1).column_vectors.reverse)

      col_pad = (foldee.column_size - folded.column_size).abs
      padding = Matrix.build(paper.row_size, col_pad) { false }

      if foldee.column_size > folded.column_size
        folded = Matrix.hstack(padding, folded)
      elsif foldee.column_size < folded.column_size
        foldee = Matrix.hstack(padding, foldee)
      end
    when "y"
      foldee = paper.minor(0...amount, 0..-1)
      folded = Matrix.rows(paper.minor(amount + 1..-1, 0..-1).row_vectors.reverse)

      row_pad = (foldee.row_size - folded.row_size).abs
      padding = Matrix.build(row_pad, paper.column_size) { false }

      if foldee.row_size > folded.row_size
        folded = Matrix.vstack(padding, folded)
      elsif foldee.row_size < folded.row_size
        foldee = Matrix.vstack(padding, foldee)
      end
    end
    Matrix.combine(foldee, folded) { |a, b| a || b }
  end
end

class OrigamiTest < Minitest::Test
  include Origami

  def test_p1
    assert_equal 17, solve_first("13/example.txt")
    assert_equal 706, solve_first("13/input.txt")
  end

  def test_p2
    example_result = <<~ASCII
      #####
      #...#
      #...#
      #...#
      #####
      .....
      .....
    ASCII

    assert_equal example_result, solve("13/example.txt")

    input_result = <<~ASCII
      #....###..####...##.###....##.####.#..#.
      #....#..#.#.......#.#..#....#.#....#..#.
      #....#..#.###.....#.###.....#.###..####.
      #....###..#.......#.#..#....#.#....#..#.
      #....#.#..#....#..#.#..#.#..#.#....#..#.
      ####.#..#.#.....##..###...##..####.#..#.
    ASCII

    assert_equal input_result, solve("13/input.txt")
  end
end
