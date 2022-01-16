require 'minitest/autorun'

module Packet
  LITERAL_WORD_LENGTH = 5

  def decode_string(str)
    @input = str
              .strip
              .chars
              .map { |x| x.to_i(16).to_s(2).rjust(4, '0') }
              .join
    decode
  end

  def decode
    version = consume!(3)
    version_sum = version
    type = consume!(3)

    if type == 4
      p decode_literal
      return version
    end

    length_type_id = consume!(1)
    amount = consume!(length_type_id == 0 ? 15 : 11)

    until @input.tr('0', '').empty? || amount == 0
      before = @input.size
      version_sum += decode
      amount -= length_type_id == 0 ? 1 : before - @input.size
    end

    version_sum
  end

  def decode_literal
    @input
      .chars
      .each_slice(LITERAL_WORD_LENGTH)
      .reduce(['', 0, false]) do |(buf, consumed, seen_last), bits|
        break [buf, consumed, true] if seen_last # The last slice was last slice, so stop.

        [buf << bits[1..].join, consumed + bits.size, bits[0] == '0' ]
      end
      .then { |(buf, consumed, _seen_last)| consume!(consumed) ; buf.to_i(2) }
  end

  def consume!(n)
    @input.slice!(0...n).to_i(2)
  end
end

class PacketTest < Minitest::Test
  include Packet

  def test_p1
    assert_equal 16, decode_string('8A004A801A8002F478')
    assert_equal 12, decode_string('620080001611562C8802118E34')
    assert_equal 23, decode_string('C0015000016115A2E0802F182340')
    assert_equal 31, decode_string('A0016C880162017C3686B18A3D4780')
    assert_equal 963, decode_string(File.read('16/input.txt'))
  end
end