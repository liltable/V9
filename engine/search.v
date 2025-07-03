module engine

import time { StopWatch }
import chess { Move }
import math { max } 

struct Search	
{
	mut:
	time_limit int
	pub mut:
	comms chan string
	nodes int
	depth int
	root_move Move
	timer StopWatch
	active bool
	overtime bool
	tt TranspositionTable = TranspositionTable.new(64)

}

pub fn (mut search Search) set_time_limit(limit int) {
	search.time_limit = limit
}

pub fn (mut search Search) set_comms_channel(channel chan string) {
	search.comms = channel
}

pub fn (mut search Search) check_time() {
	search.overtime = search.timer.elapsed().milliseconds() >= search.time_limit
}

pub fn (mut bot Engine) start_search() {
	bot.search.active = true
	bot.search.timer.start()

	spawn bot.iterate(bot.search.comms)

	for {
		output := <-bot.search.comms or { continue }

		bot.output <- output.str()

		if output.str().split_by_space()[0] == 'bestmove' {
			break
		}
	}
}

pub fn (mut bot Engine) iterate(output chan string) {
	mut depth := 2
	mut input := ''
	alpha, beta := -9999999, 9999999

	mut completed_searches := []Move{}
	
	for {
		bot.search.check_time()
		input = ''

		output.try_pop(mut input)

		if input == "stop" || bot.search.overtime { 
			break
		} 

		depth++
		completed_searches << bot.search.root_move
		score := bot.negamax(depth, 0, alpha, beta)

		output <- "info depth ${depth} score cp ${score}"
	}

	output <- "bestmove ${completed_searches.last().lan()}"
}

pub fn (mut bot Engine) negamax(depth int, ply int, a int, b int) int {
	mut alpha, mut beta := a, b

	bot.search.nodes++

	if (bot.search.nodes & 4095) > 0 {
		bot.search.check_time()
	}

	if depth <= 0 {
		return bot.board.score()
	}

	bot.search.nodes++

	mut best_score := -999999

	moves := bot.board.get_moves(false)

	for move in moves {
		bot.board.make_move(move)
		score := -bot.negamax(depth - 1, ply + 1, -beta, -alpha)
		bot.board.undo_move()

		if score > best_score {
			best_score = score
			if ply == 0 && !bot.search.overtime { bot.search.root_move = move}
			alpha = max(alpha, best_score)
		}

		if alpha >= beta { break }
		if bot.search.overtime { break }
	}

	return best_score
}