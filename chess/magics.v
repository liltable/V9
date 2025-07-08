module chess

pub struct Magic {
	pub:
	mask Bitboard
	magic Bitboard
	bits u8
	offset int 
}

pub fn magic_index(entry Magic, blockers Bitboard) usize {
	relevant_blockers := blockers & entry.mask
	hash := relevant_blockers * entry.magic
	
	return usize(entry.offset) + usize(hash >> entry.bits)
}

pub enum Slider {
	bishop
	rook
}

fn (s Slider) relevant_blockers(square int) Bitboard {
	match s {
		.bishop {
			return bishop_relevant_squares[square]
		}
		.rook {
			return rook_relevant_squares[square]
		}
	}
}

fn (s Slider) moves(square int, blockers Bitboard) Bitboard {
	match s {
		.bishop {
			return bishop_attacks(square, blockers)
		}
		.rook {
			return rook_attacks(square, blockers)
		}
	}
}

pub fn (s Slider) entries(index int) Magic
{
	match s {
		.bishop { return bishop_magics[index] }
		.rook { return rook_magics[index] }
	}
} 

pub fn (s Slider) table_size() int {
	match s {
		.bishop { return bishop_table_size }
		.rook { return rook_table_size }
	}
}

pub fn fast_bishop_moves(sq int, blockers Bitboard) Bitboard {
	entry := bishop_magics[sq]
	assert entry.mask == bishop_relevant_squares[sq]
	return bishop_magic_moves[magic_index(entry, blockers)]
}

pub fn fast_rook_moves(sq int, blockers Bitboard) Bitboard {
	entry := rook_magics[sq]
	assert entry.mask == rook_relevant_squares[sq]
	return rook_magic_moves[magic_index(entry, blockers)]
}

pub fn fast_queen_moves(sq int, blockers Bitboard) Bitboard {
	return fast_bishop_moves(sq, blockers) | fast_rook_moves(sq, blockers)
}

