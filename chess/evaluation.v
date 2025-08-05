module chess

import math
import arrays

pub struct MaterialCounter {
  pub mut:
  mg [3]int
  eg [3]int
  gamephase int
}

pub fn (mut eval MaterialCounter) remove_piece(piece Piece, from int) {
  side := piece.color()
  kind := piece.type()


  psqt_mg, psqt_eg := read_psqt(piece, from)

  eval.mg[side] -= mg_value[kind] + psqt_mg
  eval.eg[side] -= eg_value[kind] + psqt_eg

  eval.gamephase -= gamephase_inc[kind]
}

pub fn (mut eval MaterialCounter) add_piece(piece Piece, to int) {
  side := piece.color()
  kind := piece.type()

  psqt_mg, psqt_eg := read_psqt(piece, to)

  eval.mg[side] += mg_value[kind] + psqt_mg
  eval.eg[side] += eg_value[kind] + psqt_eg

  eval.gamephase += gamephase_inc[kind]
}

pub fn (mut eval MaterialCounter) move_piece(piece Piece, from int, to int) {
  side := piece.color()

  from_mg, from_eg := read_psqt(piece, from)
  to_mg, to_eg := read_psqt(piece, to)

  eval.mg[side] -= from_mg
  eval.eg[side] -= from_eg

  eval.mg[side] += to_mg
  eval.eg[side] += to_eg
}


pub fn (eval MaterialCounter) score(stm Color) int {
  opp := stm.opp()

  mg_score := eval.mg[stm] - eval.mg[opp]
  eg_score := eval.eg[stm] - eval.eg[opp]
  mg_phase := math.min(eval.gamephase, 24)
  eg_phase := 24 - mg_phase

  return ((mg_score * mg_phase) + (eg_score * eg_phase)) / 24

}

pub fn (board Board) score() int {
  if board.draw_counter >= 100 || board.is_repeated_position() { return 0 }
  
  us := board.turn

  return board.lazy_eval.score(us)
}

pub fn (board Board) is_repeated_position() bool {
  return board.hash in board.states.map(it.hash)
}

pub fn (board Board) is_threefold_repetition() bool {
  list := arrays.map_of_counts[chess.Bitboard](board.states.map(it.hash))

  return list[board.hash] > 1
}