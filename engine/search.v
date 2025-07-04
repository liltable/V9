module engine

import time { StopWatch }
import chess { Move }
import math { max } 

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
	tt TranspositionTable = TranspositionTable.new(64)
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
	bot.search.timer.start()

	spawn bot.iterate()

	for {
		output := <-bot.search.comms or { continue }

		bot.output <- output.str()

		if output.str().split_by_space()[0] == 'bestmove' {
			break
		}
	}
}

pub fn (mut bot Engine) iterate() {
	mut depth := 1
	mut input := ''
	alpha, beta := -9999999, 9999999

	mut completed_searches := []Move{}
	
	for depth < max_depth {
		bot.search.check_time()
		input = ''

		bot.search.comms.try_pop(mut input)

		depth++
		completed_searches << bot.search.pv.best_move()
		score := bot.negamax(depth, 0, alpha, beta)

		pv := bot.search.pv.mainline()

		if pv.len > 0 {
			bot.search.comms <- "info depth ${depth} score cp ${score} nodes ${bot.search.nodes} time ${bot.search.timer.elapsed().milliseconds()} pv ${bot.search.pv.mainline()}"
		}

		if bot.search.overtime || input == 'stop' { 
			break
		}
	}

	bot.search.comms <- "bestmove ${bot.search.pv.best_move().lan()}"
	bot.search.active = false
}

pub fn (mut bot Engine) negamax(depth int, ply int, a int, b int) int {
	mut alpha, mut beta := a, b

	bot.search.nodes++
	bot.search.pv.set_length(ply)

	if (bot.search.nodes & 4095) > 0 {
		bot.search.check_time()
	}

	if depth <= 0 {
		return bot.board.score()
	}

	bot.search.nodes++

	mut best_score := -999999
	mut best_move := null_move

	moves := bot.board.get_moves(false)

	for move in moves {
		bot.board.make_move(move)
		score := -bot.negamax(depth - 1, ply + 1, -beta, -alpha)
		bot.board.undo_move()

		if score > best_score {
			best_score = score

			if best_score > alpha {
				alpha = best_score

				if !bot.search.overtime {
					best_move = move

					bot.search.pv.update(best_move, ply)
				}
			}
		}

		if alpha >= beta { break }
		if bot.search.overtime { break }
	}


	return best_score
}