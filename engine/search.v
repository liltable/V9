module engine

import time { StopWatch }
import chess { Move, Bitboard, Color, MoveList }

const null_move = Move(0)

struct Search	
{
	mut:
	time_limit int
	pub mut:
	comms chan string
	nodes int
	depth int
	timer StopWatch
	active bool
	overtime bool
	pv PVTable
}

pub fn (mut search Search) set_time_limit(limit int) {
	search.time_limit = limit
}

pub fn (mut search Search) set_comms_channel(channel chan string) {
	search.comms = channel
}

pub fn (mut search Search) check_time() {
	mut stop := ''
	search.comms.try_pop(mut stop)
	search.overtime = search.timer.elapsed().milliseconds() >= search.time_limit || stop == "stop"
}

pub fn (bot Engine) score() int {
	if bot.board.draw_counter >= 100 || bot.board.repetitions.is_real_draw(bot.board.position_hash) {
		return 0
	} else {
		return bot.board.score()
	}
}

pub fn (mut bot Engine) start_search() {
	bot.search.active = true
	bot.search.nodes = 0
	bot.search.timer.start()
	bot.search.pv.reset()

	go bot.iterate()

	for {
		output := <-bot.search.comms or { continue }

		bot.output <- output.str()

		if output.str().split_by_space()[0] == 'bestmove' {
			break
		}
	}
}

pub fn (bot Engine) get_zobrist_key() Bitboard {
	mut key := bot.board.position_hash

	key ^= chess.zobrist.castling_keys[bot.board.castling_rights]

	if bot.board.en_passant_file > 0 {
		key ^= chess.zobrist.en_passant_keys[bot.board.en_passant_file.lsb() & 7]
	}

	if bot.board.turn == Color.black {
		key ^= chess.zobrist.side_key
	}

	return key
}

pub fn (mut bot Engine) iterate() {
	mut depth := 1
	mut input := ''
	mut completed_searches := []Move{}
	alpha, beta := -9999999, 9999999
	
	for depth < max_depth {
		bot.search.check_time()
		input = ''
		bot.search.comms.try_pop(mut input)
		score := bot.negamax(depth, 0, alpha, beta)
		pv := bot.search.pv.mainline()
		time_taken := bot.search.timer.elapsed().milliseconds()

		if input == 'stop' || bot.search.overtime { 
			break
		}

		bot.search.comms <- "info depth ${depth} score cp ${score} time ${time_taken} nodes ${bot.search.nodes} pv ${pv}"

		completed_searches << bot.search.pv.best_move()

		if time_taken > bot.search.time_limit / 2 { break }
		depth++
	}

	// ensures that we NEVER not have a move even if we're using like 1ms to think
	result := if completed_searches.len > 0 { completed_searches.last() } else { 
		if bot.search.pv.best_move() != null_move {
			bot.search.pv.best_move()
		} else {
			bot.random_move()
		}
	}

	bot.search.comms <- "bestmove ${result.lan()}"
	bot.search.active = false
	bot.search.timer.stop()
}

pub fn (mut bot Engine) negamax(d int, ply int, a int, b int) int {
	bot.search.pv.set_length(ply)
	bot.search.nodes++	

	mut alpha, mut beta := a, b
	mut depth := d

	if (bot.search.nodes & 2047) > 0 {
		bot.search.check_time()
	}

	// if depth > 2 && bot.search.overtime { return alpha }

	// if depth < 2 && !in_check { return bot.quiesence(alpha, beta) }

	if depth <= 0 {
		return bot.score()
	}

	mut best_score := -9999999
	mut best_move := null_move
	mut move_picker := bot.board.get_moves(.all)
	mut moves_searched := 0

	// if found_entry.move != null_move {
	// 	move_picker.set_entry_move(found_entry.move)
	// }

	for {
		move := move_picker.next().move
		if move == null_move || bot.search.overtime { break }

		bot.board.make_move(move)
		score := -bot.negamax(depth - 1, ply + 1, -beta, -alpha)
		bot.board.undo_move()

		moves_searched++

		if score > best_score {
			best_score = score

			if score > alpha {
				alpha = score

				if alpha >= beta { break }

				best_move = move

				bot.search.pv.update(best_move, ply)
				
			}
		}
	}

	if moves_searched == 0 {
		if bot.board.direct_check() {
			return ply + best_score 
		} else {
			return 0 
		}
	}

	return best_score
}