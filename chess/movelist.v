module chess

pub const max_moves = 218


// custom move list struct to avoid dynamic array allocations
pub struct MoveList {
	pub mut:
	count int
	moves [max_moves]chess.Move
	pointer int = -1
}

pub fn (mut list MoveList) add_move(move Move) {
	if list.count < max_moves {
		list.moves[list.count] = move
		list.count++
	}
}

pub fn (list MoveList) to_array() []chess.Move {
	return list.moves[0..list.count]
}

pub fn (mut list MoveList) next() chess.Move {
	list.pointer++

	if list.pointer < list.count {
		best_move := list.moves[list.pointer]

		return best_move
	}

	return chess.null_move 
}

/*
	- data_to_array[T]() => 
	a function that creates a mutable slice of a fixed-size array
	as a dynamic array using the same memory as the orginal fixed-size array 
	since V doesn't allow it by default
	(so much for being safe)
*/
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