module chess

import math

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

  if board.draw_counter >= 100 { return 0 }
  
  us := board.turn
//   opp := us.opp()

//   mut mg, mut eg := [3]int{}, [3]int{}
//   mut gamephase := 0

//  mut bitboards := board.bitboards

//   for mut pieces in bitboards {
//     for pieces > 0 {
//       square := pieces.pop_lsb()
//       piece := board.pieces[square]
//       type := int(piece.type())
//       color := int(piece.color())

//       psqt_mg, psqt_eg := read_psqt(piece, square)

//       mg[color] += mg_value[type] + psqt_mg
//       eg[color] += eg_value[type] + psqt_eg

//       gamephase += gamephase_inc[type]
//     }
//   }

//   mg_score := mg[us] - mg[opp]
//   eg_score := eg[us] - eg[opp]
//   mg_phase := min(gamephase, 24)
//   eg_phase := 24 - mg_phase

//   return (mg_score * mg_phase + eg_score * eg_phase) / 24

  return board.lazy_eval.score(us)
}


