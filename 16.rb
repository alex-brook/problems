require 'minitest/autorun'
module Packet
  def to_b(hex)
    hex.chars.map { |hx| hx.to_i(16).to_s(2).rjust(4, '0') }.join
  end

  def parse(bits)
    ((version, type), bits) = parse_header(bits)
    if type == 4
      parse_literal(bits)
    else
      parse_operator(bits, type)
    end
  end

  def parse_header(bits)
    version, bits = read(bits, 3)
    type, bits = read(bits, 3)
    [[version, type], bits]
  end

  def parse_literal(bits)
    consumed = 0
    buf = ''
    loop do
      sentinel = bits[consumed]
      buf << bits[(consumed + 1)..(consumed + 4)]
      consumed += 5
      break if sentinel == '0'
    end

    [buf.to_i(2), bits[consumed..]]
  end

  def parse_operator(bits, type)
    ((length_type_id, length), bits) = parse_operator_length(bits)
    bits_consumed = 0
    packets_consumed = 0
    values = []
    loop do
      (value, new_bits) = parse(bits)
      values << value
      bits_consumed += bits.size - new_bits.size
      bits = new_bits
      packets_consumed += 1

      break if length_type_id == 0 && bits_consumed >= length
      break if length_type_id == 1 && packets_consumed >= length
    end

    result =  case type
              when 0
                values.sum
              when 1
                values.reduce(&:*)
              when 2
                values.min
              when 3
                values.max
              when 5
                values[0] > values[1] ? 1 : 0
              when 6
                values[0] < values[1] ? 1 : 0
              when 7
                values[0] == values[1] ? 1 : 0
              else
                raise 'Unknown operator'
              end

    [result, bits]
  end

  def parse_operator_length(bits)
    (length_type_id, bits) = read(bits, 1)
    (length, bits) = read(bits, length_type_id == 0 ? 15 : 11)

    [[length_type_id, length], bits]
  end

  def read(bits, n)
    [bits[...n].to_i(2), bits[n..]]
  end
end

class PacketTest < Minitest::Test
  include Packet

  # part 1 tests omitted because implementation changed

  def test_conversion
    assert_equal '1110110111000011', to_b('EDC3')
    assert_equal '1011000000001011000100110101', to_b('B00B135')
    assert_equal '1111111011101101', to_b('FEED')
    assert_equal '111110101100', to_b('FAC')
  end

  def test_header
    assert_equal [[6, 4], '101111111000101000'], parse_header('110100101111111000101000')
  end

  def test_literal
    assert_equal [2021, '000'], parse_literal('101111111000101000')
    assert_equal [2021, '000'], parse('110100101111111000101000')
    assert_equal [5000000000, '0'], parse('0011001000110010110101000010101111111001010000000000')
  end

  def test_operator_length
    assert_equal [[0, 27], '1101000101001010010001001000000000'], parse_operator_length('00000000000110111101000101001010010001001000000000')
    assert_equal [[1, 3], '01010000001100100000100011000001100000'], parse_operator_length('10000000001101010000001100100000100011000001100000')
  end

  def test_operator
    assert_equal [3, '00000'], parse('11101110000000001101010000001100100000100011000001100000')
    assert_equal [3, ''], parse(to_b('C200B40A82'))
    assert_equal [54, '0000'], parse(to_b('04005AC33890'))
    assert_equal [7, '0'], parse(to_b('880086C3E88112'))
    assert_equal [9, '00000'], parse(to_b('CE00C43D881120'))
    assert_equal [1, '0000'], parse(to_b('D8005AC2A8F0'))
    assert_equal [0, ''], parse(to_b('F600BC2D8F'))
    assert_equal [0, '0000'], parse(to_b('9C005AC2F8F0'))
    assert_equal [1, '00'], parse(to_b('9C0141080250320F1802104A08'))
    assert_equal [1549026292886, '0000000'], parse(to_b(File.read('16/input.txt').strip))
  end
end