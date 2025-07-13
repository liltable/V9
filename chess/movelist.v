module chess

pub const max_moves = 218

// custom move list struct to avoid dynamic array allocations
pub struct MoveList {
	pub mut:
	count int
	moves [max_moves]Move
	pointer int = -1
}

pub fn (mut list MoveList) add_move(move Move) {
	if list.count < max_moves {
		list.moves[list.count] = move
		list.count++
	}
}

pub fn (list MoveList) get_move(index int) Move {
	if index < list.count {
		return list.moves[index]
	}

	return null_move
}

pub fn (mut list MoveList) clear() {
	list.count = 0
	list.moves = [max_moves]Move{}
}

pub fn (list MoveList) to_array() []Move {
	return list.moves[0..list.count]
}

pub fn (mut list MoveList) next() Move {
	list.pointer++

	if list.pointer < list.count {
		best_move := list.moves[list.pointer]

		return best_move
	}

	return null_move 
}