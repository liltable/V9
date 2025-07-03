module engine

import time { StopWatch }
import chess { Move }

struct Search	
{
	mut:
	time_limit int
	comms chan string
	pub mut:
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
	search.overtime = search.timer.elapsed().milliseconds() >= search.time_limit || <- search.comms == "stop"
}

pub fn (mut bot Engine) start_search() {
	bot.search.active = true
	bot.search.timer.start()


	spawn bot.iterate(bot.search.comms)

	for {
		output := <-bot.search.comms

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

	output <- "info string hi"
	
	for {
		bot.search.check_time()
		input = ''

		output.try_pop(mut input)

		if input == "stop" || bot.search.overtime { 
			output <- 'stopping search'
			break
		} 

		depth++
		// score := bot.negamax(depth, 0, alpha, beta)

		output <- "info depth ${depth}"
	}

	output <- "bestmove ${bot.random_move().lan()}"
}

pub fn (mut bot Engine) negamax(depth int, ply int, alpha int, beta int) int {
	if depth <= 0 {
		return bot.board.score()
	}

	bot.search.nodes++

	mut best_score := -999999

	return best_score
}