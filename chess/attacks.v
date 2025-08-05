module chess

pub fn get_pawn_attacks(sq int, side Color) Bitboard {
	from := square_bbs[sq].forward(side)

	left := from.left() & ~file_h
	right := from.right() & ~file_a

	return left | right
}

pub fn get_knight_attacks(sq int) Bitboard {
	from := square_bbs[sq]

	not_hg := ~(file_h | file_g)
	not_ab := ~(file_a | file_b)

	// shift directions are annoying, using raw numbers since its like up up right up right right in all 4 directions

	mut attack := empty_bb

	attack |= (from << 6) & not_hg
	attack |= (from << 10) & not_ab
	attack |= (from << 15) & ~file_h
	attack |= (from << 17) & ~file_a

	attack |= (from >> 6) & not_ab
	attack |= (from >> 10) & not_hg
	attack |= (from >> 15) & ~file_a
	attack |= (from >> 17) & ~file_h

	return attack
}

pub fn get_king_attacks(sq int) Bitboard {
	king := square_bbs[sq]

	mut attacks := empty_bb

	attacks |= king.up()
	attacks |= king.right() & ~file_a
	attacks |= king.left() & ~file_h
	attacks |= king.down()

	attacks |= king.up().right() & ~file_a
	attacks |= king.down().right() & ~file_a
	attacks |= king.up().left() & ~file_h
	attacks |= king.down().left() & ~file_h

	return attacks
}

pub fn get_bishop_attacks(sq int, blockers Bitboard) Bitboard {
	mut attacks := empty_bb

	rank, file := sq >> 3, sq & 7 // square / 8, square % 8

	mut r, mut f := rank, file

	for r < 7 && f < 7 {
		r++
		f++
		bit := square_bbs[r * 8 + f]

		attacks |= bit

		if (blockers & bit) > 0 {
			break
		}
	}

	r, f = rank, file

	for r > 0 && f < 7 {
		r--
		f++
		bit := square_bbs[r * 8 + f]

		attacks |= bit

		if (blockers & bit) > 0 {
			break
		}
	}

	r, f = rank, file

	for r < 7 && f > 0 {
		r++
		f--
		bit := square_bbs[r * 8 + f]

		attacks |= bit

		if (blockers & bit) > 0 {
			break
		}
	}

	r, f = rank, file

	for r > 0 && f > 0 {
		r--
		f--
		bit := square_bbs[r * 8 + f]

		attacks |= bit

		if (blockers & bit) > 0 {
			break
		}
	}

	r, f = rank, file

	attacks &= ~square_bbs[sq] // failsafe, ensure that the square we're on isn't an attackable square

	return attacks
}

pub fn get_rook_attacks(sq int, blockers Bitboard) Bitboard {
	mut attacks := empty_bb

	rank, file := sq >> 3, sq & 7 // square / 8, square % 8

	mut r, mut f := rank, file

	for r < 7 {
		r++
		bit := square_bbs[r * 8 + f]

		attacks |= bit

		if (blockers & bit) > 0 {
			break
		}
	}

	r, f = rank, file

	for r > 0 {
		r--
		bit := square_bbs[r * 8 + f]

		attacks |= bit

		if (blockers & bit) > 0 {
			break
		}
	}

	r, f = rank, file

	for f < 7 {
		f++
		bit := square_bbs[r * 8 + f]

		attacks |= bit

		if (blockers & bit) > 0 {
			break
		}
	}

	r, f = rank, file

	for f > 0 {
		f--
		bit := square_bbs[r * 8 + f]

		attacks |= bit

		if (blockers & bit) > 0 {
			break
		}
	}

	r, f = rank, file

	attacks &= ~square_bbs[sq] // failsafe, ensure that the square we're on isn't an attackable square

	return attacks
}

pub fn get_queen_attacks(sq int, blockers Bitboard) Bitboard {
	return get_rook_attacks(sq, blockers) | get_bishop_attacks(sq, blockers)
}
