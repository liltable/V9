  module engine

import chess

const global_tt_size_mb = 128

pub enum EntryType {
	invalid
	lowerbound
	upperbound
	exact
}

struct TranspositionEntry {
pub:
	key   chess.Bitboard
	score int
	depth int
	move  chess.Move
	type  EntryType
}

pub const null_tt_entry = TranspositionEntry{}

struct TranspositionTable {
mut:
	entries []TranspositionEntry
	size    u64
}

pub fn TranspositionTable.new(size_mb int) TranspositionTable {
	entry_size := sizeof(TranspositionEntry)
	table_size_bytes := size_mb * 1024 * 1024
	entry_count := table_size_bytes / int(entry_size)

	table := []TranspositionEntry{len: entry_count}

	return TranspositionTable{table, u64(entry_count)}
}

pub fn (mut table TranspositionTable) insert(entry TranspositionEntry) {
	key := entry.key % table.size
	table.entries[key] = entry
}

pub fn (table TranspositionTable) lookup(key chess.Bitboard) TranspositionEntry {
	return table.entries[key % table.size]
}

pub fn (mut table TranspositionTable) clear() {
	table.entries = []TranspositionEntry{len: int(table.size)}
}
