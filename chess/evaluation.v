module chess

import math { min }

pub fn (board Board) score() int {

  if board.repetitions.is_draw(board.position_hash) || board.draw_counter >= 100 { return 0 }

  us := board.turn
  opp := us.opp()

  mut mg, mut eg := [3]int{}, [3]int{}
  mut gamephase := 0

 mut bitboards := board.bitboards

  for mut pieces in bitboards {
    for pieces > 0 {
      square := pieces.pop_lsb()
      piece := board.pieces[square]
      type := int(piece.type())
      color := int(piece.color())

      psqt_mg, psqt_eg := read_psqt(piece, square)

      mg[color] += mg_value[type] + psqt_mg
      eg[color] += eg_value[type] + psqt_eg

      gamephase += gamephase_inc[type]
    }
  }

  mg_score := mg[us] - mg[opp]
  eg_score := eg[us] - eg[opp]
  mg_phase := min(gamephase, 24)
  eg_phase := 24 - mg_phase

  return (mg_score * mg_phase + eg_score * eg_phase) / 24
}
