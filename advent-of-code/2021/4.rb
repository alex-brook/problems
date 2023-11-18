# frozen_string_literal: true

require "minitest/autorun"
require "set"

class Bingo
  BOARD_SIZE = 5

  def play_p1
    play do |card|
      # Are there any winners?
      winner = @boards.find { |board| winner?(board) }

      return winner.first.keys.sum * card if winner
    end
  end

  def play_p2
    non_winners = @boards

    play do |card|
      if non_winners.one? && winner?(non_winners.first)
        return non_winners.first.first.keys.sum * card
      end

      non_winners = @boards.filter { |board| !winner?(board) }
    end
  end

  def load(filename)
    lines = File.readlines(filename).map(&:strip).filter { |line| !line.empty? }

    @cards = load_cards(lines)
    @boards = load_boards(lines)

    self
  end

  private

  def play
    @cards.each do |card|
      @boards.each do |(lookdown, lookup)|
        next unless lookdown.key? card

        lookup.delete(lookdown[card])
        lookdown.delete(card)
      end

      yield(card)
    end
  end

  def winner?(board)
    _lookdown, lookup = board
    potential_winning_lines.any? { |line| line.none? { |l| lookup.key? l } }
  end

  def potential_winning_lines
    coords = (0...BOARD_SIZE).to_a.repeated_permutation(2)

    [
      *coords.sort.chunk(&:first).map(&:last),
      *coords.sort_by { |(row, col)| [col, row] }.chunk(&:last).map(&:last),
    ]
  end

  def load_cards(lines)
    lines.first.split(",").map(&:to_i)
  end

  def load_boards(lines)
    lines[1..]
      .each_slice(BOARD_SIZE)
      .map { |board| board.map { |row| row.split.map(&:to_i) } }
      .map do |board|
      lookup =
        (0...BOARD_SIZE)
          .to_a
          .repeated_permutation(2)
          .map { |(row, col)| [[row, col], board[row][col]] }
          .to_h

      [lookup.to_a.map(&:reverse).to_h, lookup]
    end
  end
end

class BingoTest < Minitest::Test
  def setup
    @game = Bingo.new
  end

  def test_p1
    assert_equal 4512, @game.load("4/example.txt").play_p1
    assert_equal 55_770, @game.load("4/input.txt").play_p1
  end

  def test_p2
    assert_equal 1924, @game.load("4/example.txt").play_p2
    assert_equal 2980, @game.load("4/input.txt").play_p2
  end
end
