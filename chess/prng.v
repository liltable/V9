module chess

pub struct ZRNG {
mut:
	seed Bitboard = Bitboard(1029384756)
}

// XORSHIFT32 algorithm for psuedorandom number generation.
pub fn (mut z ZRNG) roll() Bitboard {
	mut x := z.seed

	x ^= x << 13
	x ^= x >> 17
	x ^= x << 5

	z.seed = x

	return x
}

__global (
	xs32 ZRNG
)
