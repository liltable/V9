module engine

import time { StopWatch }
import chess { Move, Bitboard, Color }

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

pub fn (mut bot Engine) start_search() {
	bot.search.active = true
	bot.search.nodes = 0
	bot.search.timer.start()
	bot.search.pv.reset()

	spawn bot.iterate()

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

		time_taken := bot.search.timer.elapsed().milliseconds()

		if time_taken > bot.search.time_limit || input == 'stop' { 
			break
		}

		pv := bot.search.pv.mainline()

		bot.search.comms <- "info depth ${depth} score cp ${score} time ${time_taken} nodes ${bot.search.nodes} pv ${pv}"
		
		completed_searches << bot.search.pv.best_move()
		depth++
	}

	bot.search.comms <- "bestmove ${completed_searches.last().lan()}"
	bot.search.active = false
}

pub fn (mut bot Engine) negamax(d int, ply int, a int, b int) int {
	bot.search.pv.set_length(ply)

	mut alpha, mut beta := a, b
	mut depth := d

	if (bot.search.nodes & 2047) > 0 {
		bot.search.check_time()
	}

	if depth > 2 && bot.search.overtime { return alpha }

	bot.search.nodes++	

	if depth <= 0 {
		return bot.board.score()
	}

	mut best_score := -9999999
	mut best_move := null_move

	mut moves := bot.board.get_moves(false)

	for move in moves {
		bot.board.make_move(move)
		score := -bot.negamax(depth - 1, ply + 1, -beta, -alpha)
		bot.board.undo_move()

		if score > best_score {
			best_score = score

			if best_score > alpha {
				alpha = best_score
				best_move = move

				bot.search.pv.update(best_move, ply)
	
			}
		}

		if alpha >= beta {
			break
		}
	}
	
	return best_score
}