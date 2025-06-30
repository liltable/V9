module chess

import os

pub enum Square {
	@none = -1
	a1
	b1
	c1
	d1
	e1
	f1
	g1
	h1
	a2
	b2
	c2
	d2
	e2
	f2
	g2
	h2
	a3
	b3
	c3
	d3
	e3
	f3
	g3
	h3
	a4
	b4
	c4
	d4
	e4
	f4
	g4
	h4
	a5
	b5
	c5
	d5
	e5
	f5
	g5
	h5
	a6
	b6
	c6
	d6
	e6
	f6
	g6
	h6
	a7
	b7
	c7
	d7
	e7
	f7
	g7
	h7
	a8
	b8
	c8
	d8
	e8
	f8
	g8
	h8
}

pub const square_names = [
	Square.a1,
	Square.b1,
	Square.c1,
	Square.d1,
	Square.e1,
	Square.f1,
	Square.g1,
	Square.h1,
	Square.a2,
	Square.b2,
	Square.c2,
	Square.d2,
	Square.e2,
	Square.f2,
	Square.g2,
	Square.h2,
	Square.a3,
	Square.b3,
	Square.c3,
	Square.d3,
	Square.e3,
	Square.f3,
	Square.g3,
	Square.h3,
	Square.a4,
	Square.b4,
	Square.c4,
	Square.d4,
	Square.e4,
	Square.f4,
	Square.g4,
	Square.h4,
	Square.a5,
	Square.b5,
	Square.c5,
	Square.d5,
	Square.e5,
	Square.f5,
	Square.g5,
	Square.h5,
	Square.a6,
	Square.b6,
	Square.c6,
	Square.d6,
	Square.e6,
	Square.f6,
	Square.g6,
	Square.h6,
	Square.a7,
	Square.b7,
	Square.c7,
	Square.d7,
	Square.e7,
	Square.f7,
	Square.g7,
	Square.h7,
	Square.a8,
	Square.b8,
	Square.c8,
	Square.d8,
	Square.e8,
	Square.f8,
	Square.g8,
	Square.h8,
]

pub fn in_between(sq1 int, sq2 int) Bitboard {
	m1 := u64(-1)
	a2a7 := u64(0x0001010101010100)
	b2g7 := u64(0x0040201008040200)
	h1b7 := u64(0x0002040810204080)

	mut btwn := u64((m1 << sq1) ^ (m1 << sq2))
	mut file := u64((sq2 & 7) - (sq1 & 7))
	mut rank := u64(((sq2 | 7) - sq1) >> 3)
	mut line := u64(((file & 7) - 1) & a2a7)

	line += 2 * (((rank & 7) - 1) >> 58)
	line += (((rank - file) & 15) - 1) & b2g7
	line += (((rank + file) & 15) - 1) & h1b7
	line *= btwn & -btwn

	return Bitboard(line & btwn)
}

fn gen_ray_attacks() ! {
	mut lines := []string{}

	lines << '['

	for sq1 := 0; sq1 < 64; sq1++ {
		lines << '['
		for sq2 := 0; sq2 < 64; sq2++ {
			if sq2 == 0 {
				lines << 'Bitboard(${in_between(sq1, sq2)}),'
			} else {
				lines << '${in_between(sq1, sq2)},'
			}
		}
		lines << '],'
	}

	lines << ']'

	os.write_lines('./maybe.txt', lines)!
}
