module engine

import chess

pub struct PVTable {
	mut:
	lines [max_depth][max_depth]chess.Move
	line_lengths [max_depth]int
}

pub fn (mut table PVTable) reset() {
	table.lines = [max_depth][max_depth]chess.Move{}
	table.line_lengths = [max_depth]int{}
}

pub fn (mut table PVTable) update(move chess.Move, ply int) {
	table.lines[ply][ply] = move

	for i := ply + 1; i < table.line_lengths[ply + 1]; i++ {
		table.lines[ply][i] = table.lines[ply + 1][i]
	}

	table.line_lengths[ply] = table.line_lengths[ply + 1]
}

pub fn (mut table PVTable) set_length(ply int) {
	table.line_lengths[ply] = ply
}

pub fn (table PVTable) mainline() string {
	 mut s := ''
	
	for i := 0; i < table.line_lengths[0]; i++ {
		s += "${table.lines[0][i].lan()} "
	}

	 return s
}

pub fn (table PVTable) best_move() chess.Move {
	return table.lines[0][0]
}