  module engine

import chess { Bitboard, Move }

const global_tt_size_mb = 128
const tt_entry_cap = 5592405

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
	move  Move
	type  EntryType
}

pub const null_tt_entry = TranspositionEntry{}

struct TranspositionTable {
mut:
	entries [tt_entry_cap]TranspositionEntry
	size int = tt_entry_cap
}

pub fn (mut table TranspositionTable) insert(entry TranspositionEntry) {
	table.entries[entry.key % u64(table.size)] = entry
}

pub fn (table TranspositionTable) lookup(key Bitboard) TranspositionEntry {
	return table.entries[key % u64(table.size)]
}

pub fn (mut table TranspositionTable) clear() {
	table.entries = [tt_entry_cap]TranspositionEntry{}
}
