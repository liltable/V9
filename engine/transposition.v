  module engine

import chess { Bitboard }

pub enum EntryType {
	invalid
	lowerbound
	upperbound
	exact
}

struct TranspositionEntry {
pub:
	key   Bitboard
	score int
	depth int
	type  EntryType
}

pub const null_tt_entry = TranspositionEntry{}

struct TranspositionTable {
mut:
	entries []TranspositionEntry
	size    int
}

pub fn TranspositionTable.new(size_mb int) TranspositionTable {
	entry_size := sizeof(TranspositionEntry)
	table_size_bytes := size_mb * 1024 * 1024
	entry_count := table_size_bytes / int(entry_size)

	table := []TranspositionEntry{len: entry_count}

	return TranspositionTable{table, entry_count}
}

pub fn (mut table TranspositionTable) insert(entry TranspositionEntry) {
	table.entries[entry.key % u64(table.size)] = entry
}

pub fn (table TranspositionTable) lookup(key Bitboard) TranspositionEntry {
	return table.entries[key % u64(table.size)]
}

pub fn (mut table TranspositionTable) clear() {
	for i, _ in table.entries {
		table.entries[i] = null_tt_entry
	}
}
