module chess

import log
import math.bits

pub type Bitboard = u64

pub const empty_bb = Bitboard(0)
pub const max_bb = Bitboard(0xFFFFFFFFFFFFFFFF)

pub enum Bitboards {
	none
	pawns
	knights
	bishops
	rooks
	queens
	kings
}

pub enum Occupancies {
	both
	white
	black
}

pub fn (b Bitboard) up() Bitboard {
	return Bitboard(b << 8)
}

pub fn (b Bitboard) down() Bitboard {
	return Bitboard(b >> 8)
}

pub fn (b Bitboard) left() Bitboard {
	return Bitboard(b >> 1)
}

pub fn (b Bitboard) right() Bitboard {
	return Bitboard(b << 1)
}

pub fn (b Bitboard) forward(color Color) Bitboard {
	return if color == .white { b.up() } else { b.down() }
}

pub fn (b Bitboard) str() string {
	return '0x${u64(b):X}'
}

pub fn (mut b Bitboard) pop_lsb() int {
	lsb := bits.trailing_zeros_64(b)
	b &= b - Bitboard(1)
	return lsb
}

pub fn (b Bitboard) lsb() int {
	return bits.trailing_zeros_64(b)
}

pub fn (b Bitboard) count() int {
	return bits.ones_count_64(b)
}

pub fn (b Bitboard) wrapping_mul(mul Bitboard) Bitboard {
	return (b * mul) % (Bitboard(1) << 64)
}

pub fn (b Bitboard) wrapping_sub(sub Bitboard) Bitboard {
	return (b - sub) % (Bitboard(1) << 64)
}

pub const file_a = Bitboard(0x101010101010101)
pub const file_b = Bitboard(0x202020202020202)
pub const file_c = Bitboard(0x404040404040404)
pub const file_d = Bitboard(0x808080808080808)
pub const file_e = Bitboard(0x1010101010101010)
pub const file_f = Bitboard(0x2020202020202020)
pub const file_g = Bitboard(0x4040404040404040)
pub const file_h = Bitboard(u64(0x8080808080808080))

pub const all_files = [file_a, file_b, file_c, file_d, file_e, file_f, file_g, file_h]

pub const file_symbols = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']

pub const symbol_to_file = {
	'a': file_a
	'b': file_b
	'c': file_c
	'd': file_d
	'e': file_e
	'f': file_f
	'g': file_g
	'h': file_h
}

pub const rank_1 = Bitboard(0xff)
pub const rank_2 = Bitboard(0xff00)
pub const rank_3 = Bitboard(0xff0000)
pub const rank_4 = Bitboard(0xff000000)
pub const rank_5 = Bitboard(0xff00000000)
pub const rank_6 = Bitboard(0xff0000000000)
pub const rank_7 = Bitboard(0xff000000000000)
pub const rank_8 = Bitboard(0xff00000000000000)

pub const all_ranks = [rank_1, rank_2, rank_3, rank_4, rank_5, rank_6, rank_7, rank_8]

pub const four_corners = Bitboard(0x8100000000000081)

pub fn (b Bitboard) print() {
	mut s := '\n'
	for rank := 7; rank >= 0; rank-- {
		for file := 0; file <= 7; file++ {
			index := rank * 8 + file
			bit := (Bitboard(1) << index)

			if file == 0 {
				s += (rank + 1).str() + ' |'
			}

			if (b & bit) > 0 {
				s += ' # '
			} else {
				s += ' . '
			}
		}

		s += '\n'
	}

	s += '    a  b  c  d  e  f  g  h'
	log.debug(s)
}

pub fn (b Bitboard) print_stdout() {
	mut s := '\n'
	for rank := 7; rank >= 0; rank-- {
		for file := 0; file <= 7; file++ {
			index := rank * 8 + file
			bit := (Bitboard(1) << index)

			if file == 0 {
				s += (rank + 1).str() + ' |'
			}

			if (b & bit) > 0 {
				s += ' # '
			} else {
				s += ' . '
			}
		}

		s += '\n'
	}

	s += '    a  b  c  d  e  f  g  h'
	println(s)
}

fn gen_square_bbs() []Bitboard {
	mut bbs := []Bitboard{}

	for sq := 0; sq < 64; sq++ {
		bbs << Bitboard(1) << sq
	}

	return bbs
}

pub const square_bbs = gen_square_bbs()
