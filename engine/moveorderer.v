module engine

import chess 

pub type ScoredMoveList = []ScoredMove

pub struct ScoredMove {
	move chess.Move
	score int
}

pub const null_scored_move = ScoredMove{chess.null_move, -9999999}

pub fn ScoredMoveList.new(move_list chess.MoveList, bot &Engine, ply int, entry_move chess.Move) ScoredMoveList {
	mut scored_moves := []ScoredMove{len: move_list.count}

	for idx in 0 .. move_list.count {
		mut score := 0

		move := move_list.moves[idx]

		if entry_move != chess.null_move && move == entry_move {
			score = 9_000_000
		} else if move.is_capture() {
			score = 100_000 * int(move.captured()) - int(move.piece().type())
		} else {
			if move == bot.killers[0][ply] { score += 90_000 }
			else if move == bot.killers[1][ply] { score += 80_000 }

			score += bot.history[bot.board.turn][move.from_square()][move.to_square()]
		}

		scored_moves[idx] = ScoredMove { move, score }
	}

	return ScoredMoveList(scored_moves)
}

pub fn (mut list ScoredMoveList) next_move() chess.Move {
	mut idx := 0
	mut best_move := null_scored_move
	
	for i in 0 .. list.len {
		if list[i].score > best_move.score {
			best_move = list[i]
			idx = i
		}
	}

	if list.len > 0 {
		list[idx] = null_scored_move
	}

	return best_move.move
}