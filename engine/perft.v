module engine

import time { StopWatch }

fn (mut bot Engine) internal_perft(depth int) int {
	if depth == 0 {
		return 1
	}

	moves := bot.board.get_moves(.all).to_array()

	if depth == 1 {
		return moves.len
	}

	mut nodes := 0

	for move in moves {
		bot.board.make_move(move)
		nodes += bot.internal_perft(depth - 1)
		bot.board.undo_move()
	}

	return nodes
}

pub fn (mut bot Engine) perft(depth int) {
	mut total_nodes := 0

	mut timer := StopWatch{}

	timer.start()

	moves := bot.board.get_moves(.all).to_array()

	for move in moves {
		bot.board.make_move(move)
		new_nodes := bot.internal_perft(depth - 1)
		bot.board.undo_move()

		total_nodes += new_nodes
		bot.output <- ('${move.lan()}: ${new_nodes}')
	}

	timer.stop()

	bot.output <- ('\nNodes searched: ${total_nodes}')

	time_taken := timer.elapsed().seconds()

	nps := int(total_nodes / time_taken)

	bot.output <- ('Time taken: ${time_taken}s')
	bot.output <- ('Nodes per second: ${nps}')
}
