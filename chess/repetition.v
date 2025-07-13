module chess

struct RepetitionTable {
mut:
	entries map[Bitboard]int
}

fn (mut table RepetitionTable) increment(position Bitboard) {
	if position in table.entries {
		table.entries[position]++
	} else {
		table.entries[position] = 1
	}
}

fn (mut table RepetitionTable) decrement(position Bitboard) {
	if position in table.entries {
		if table.entries[position] == 1 {
			table.entries.delete(position)
		} else {
			table.entries[position]--
		}
	}
}

pub fn (table RepetitionTable) is_real_draw(position Bitboard) bool {
	return position in table.entries && table.entries[position] >= 3
}

pub fn (table RepetitionTable) is_theoretical_draw(position Bitboard) bool {
	return position in table.entries && table.entries[position] >= 2
}
