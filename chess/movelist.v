module chess

pub const max_moves = 218

@[packed]

pub struct ScoredMove {
	pub:
	move Move
	pub mut:
	score int
}

pub const null_scored_move = ScoredMove{0, 0}

pub fn ScoredMove.new(move Move) ScoredMove {
	return ScoredMove{move, 0}
}

pub fn (mut move ScoredMove) set_score(score int) {
	move.score = score
}

// custom move list struct to avoid dynamic array allocations
pub struct MoveList {
	pub mut:
	count int
	moves [max_moves]ScoredMove
	pointer int = -1
}

pub fn (mut list MoveList) add_move(move Move) {
	if list.count < max_moves {
		list.moves[list.count] = ScoredMove.new(move)
		list.count++
	}
}

pub fn (list MoveList) get_move(index int) ScoredMove {
	if index < list.count {
		return list.moves[index]
	}

	return null_scored_move
}

pub fn (list MoveList) get_pointed() ScoredMove {
	return list.moves[list.pointer]
}

pub fn (mut list MoveList) clear() {
	list.count = 0
	list.moves = [max_moves]ScoredMove{}
}

pub fn (list MoveList) to_array() []ScoredMove {
	return list.moves[0..list.count]
}

pub fn (mut list MoveList) next() ScoredMove {
	list.pointer++

	if list.pointer < list.count {
		best_move := list.moves[list.pointer]

		return best_move
	}

	return null_scored_move 
}

pub fn data_to_array[T](start voidptr, len int) []T {
	mut section := unsafe {
		array {
			data: start
			len: len
			element_size: int(sizeof(T))
			flags: .nofree | .nogrow | .noshrink
		}
	 }

	 return section
}

pub fn (mut list MoveList) sort_moves() {
	start := &list.moves[0]
	mut section := data_to_array[ScoredMove](start, list.count)

	section.sort(a.score > b.score) // descending
}