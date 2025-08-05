module engine

import time
import chess

const null_move = chess.Move(0)

struct Search	
{
	mut:
	time_limit int
	pub mut:
	comms chan string
	nodes int
	depth int
	timer time.StopWatch
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
	if bot.board.draw_counter >= 100 {
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

pub fn (mut bot Engine) iterate() {
	mut depth := 1
	mut input := ''
	mut completed_searches := []chess.Move{}
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

	if bot.board.draw_counter >= 100 { return 0 }

	mut alpha, mut beta := a, b
	mut depth := d

	if (bot.search.nodes & 2047) > 0 {
		bot.search.check_time()
	}

	if depth <= 0 {
		return bot.score()
	}

	old_alpha := alpha
	key := bot.board.hash
	entry := bot.tt.lookup(key)
	is_valid_entry := entry.key == key
	
	mut entry_move := entry.move

	// if is_valid_entry && ply > 0 && entry.depth >= depth {
	// 	if entry.type == .exact ||
	// 	(entry.type == .upperbound && entry.score < alpha) ||
	// 	(entry.type == .lowerbound && entry.score >= beta) {
	// 		return entry.score
	// 	}
	// }

	mut best_score := -9999999
	mut best_move := null_move
	mut moves_searched := 0

	mut move_list := bot.board.get_moves(.all)
	mut scored_moves := ScoredMoveList.new(move_list, &bot, ply, entry_move)

	for {	
		move := scored_moves.next_move()
		if move == null_move || bot.search.overtime { break }
		
		bot.board.make_move(move)
		score := -bot.negamax(depth - 1, ply + 1, -beta, -alpha)
		bot.board.undo_move()

		moves_searched++

		if score > best_score {
			best_score = score

			if score > alpha {
				alpha = score

				if alpha >= beta {

					if !move.is_capture() {

						if move != bot.killers[0][ply] && move != bot.killers[1][ply] {
							bot.killers[0][ply] = bot.killers[1][ply]
							bot.killers[1][ply] = move
						}

						bot.history[bot.board.turn][move.from_square()][move.to_square()] += i16(depth * depth)
					}

					break
				}

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

	if !bot.search.overtime {
		flag := if best_score >= beta { EntryType.lowerbound } else if best_score < old_alpha { .upperbound } else { .exact }
		bot.tt.insert(TranspositionEntry { key, best_score, depth, best_move, flag })
	}

	return best_score
}