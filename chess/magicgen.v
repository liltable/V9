module chess

fn find_magic(slider Slider, square int, bits u8) (Magic, []Bitboard) {
	mask := slider.relevant_blockers(square)
	shift := 64 - bits

	for {
		magic := (xs32.roll() & xs32.roll() & xs32.roll())
		entry := Magic { mask, magic, shift, 0 }

		ok, table := try_make_table(slider, square, entry)

		if ok { return entry, table }
	}

	return Magic{}, []Bitboard{} // i need this to satisfy the compiler for some reason
}

fn try_make_table(slider Slider, square int, entry Magic) (bool, []Bitboard) {
	bits := 64 - entry.bits
	mut table := []Bitboard{len: 1 << bits, init: chess.empty_bb}

	mut blockers := Bitboard(0)

	for {
		moves := slider.moves(square, blockers)
		index := magic_index(entry, blockers)

		if table[index] == chess.empty_bb {
			table[index] = moves
		} else if table[index] != moves {
			return false, table
		}

		blockers = (blockers - entry.mask) & entry.mask

		if blockers == chess.empty_bb { break }
		
	}

	return true, table
}

pub fn print_magics(slider Slider) {
	println("pub const ${slider}_magics = [")

	mut total_size := 0

	for sq in 0 .. 64 {
		bits := u8(slider.relevant_blockers(sq).count())
		entry, table := find_magic(slider, sq, bits)

		println("	Magic { ${entry.mask}, ${entry.magic}, ${entry.bits}, ${total_size} },")

		total_size += table.len
	}

	println("]")

	println("pub const ${slider}_table_size = ${total_size}")
}

fn load_magics(slider Slider) []Bitboard {
	mut table := []Bitboard{len: slider.table_size() }

	for sq in 0 .. 64 {
		entry := slider.entries(sq)
		
		mut blockers := empty_bb

		for {
			moves := slider.moves(sq, blockers)
			index := magic_index(entry, blockers)

			table[index] = moves

			blockers = (blockers - entry.mask) & entry.mask

			if blockers == empty_bb { break }
		}
	}

	return table
}

pub const bishop_magic_moves := load_magics(.bishop)
pub const rook_magic_moves := load_magics(.rook)