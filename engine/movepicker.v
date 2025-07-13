module engine

import chess { Board, Move, MoveList }

pub enum MovegenStage {
	tt_move
	killer_move
	gen_captures
	captures
	gen_quiets
	quiets
}

pub struct MovePicker {
	entry_move Move
	killer_move Move
	mut:
	move_list MoveList
	stage MovegenStage
	board &Board
}

pub fn (mut picker MovePicker) next_stage() {

	unsafe {
		picker.stage = MovegenStage(int(picker.stage) + 1)
	}

	// this language needs better casting support
}

pub fn (picker MovePicker) pick_next_move() Move {
	mut list := &picker.move_list

	if list.pointer == list.count {
		return chess.null_move
	}

	best_move := list.next()

	if best_move == picker.entry_move || best_move == picker.killer_move {
		return picker.pick_next_move()
	}

	return best_move
}

pub fn (mut picker MovePicker) next_move() Move {

	mut move := null_move 

	match picker.stage {
		.tt_move {
			picker.next_stage()
			return picker.entry_move
		}
		.killer_move {
			picker.next_stage()

			if (picker.entry_move != picker.killer_move) && picker.board.move_is_legal(picker.killer_move) {
				return picker.killer_move
			}
		}
		.gen_captures {
			picker.move_list = picker.board.get_moves(.captures)

			picker.next_stage()
		}

		.captures {
			move = picker.pick_next_move()

			picker.next_stage()
		}

		.gen_quiets {
			picker.move_list = picker.board.get_moves(.quiets)

			picker.next_stage()
		}

		.quiets {
			move = picker.pick_next_move()
		}
	}

	return move
}

