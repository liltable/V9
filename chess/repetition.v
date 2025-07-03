module chess

import log

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
    table.entries[position]--
  } else {
    log.warn("Attempted to decrement an entry in the repetition table that doesn't exist.")
  }
}


fn (table RepetitionTable) is_draw(position Bitboard) bool {
  return position in table.entries && table.entries[position] >= 2
}
