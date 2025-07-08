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
	tt TranspositionTable = TranspositionTable.new(64)
	pv PVTable
	killers [max_depth]Move
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

		if bot.search.overtime || input == 'stop' { 
			break
		}

		pv := bot.search.pv.mainline()

		bot.search.comms <- "info depth ${depth} score cp ${score} time ${bot.search.timer.elapsed().milliseconds()} nodes ${bot.search.nodes} pv ${pv}"
		
		completed_searches << bot.search.pv.best_move()
		depth++
	}

	bot.search.comms <- "bestmove ${completed_searches.last().lan()}"
	bot.search.active = false
}

pub fn (bot Engine) guess_move_score(move Move, ply int, entry TranspositionEntry) int {
	mut guess := 0

	if move == bot.search.pv.best_move() { guess += 900_000 }
	if move == entry.move { guess += 400_000 }
	if bot.search.killers[ply] == move { guess += 50_000 }
	if move.is_capture() { guess += 1_000 }

	return guess
}

pub fn (mut bot Engine) negamax(d int, ply int, a int, b int) int {
	zobrist_key := bot.get_zobrist_key()
	bot.search.pv.set_length(ply)

	mut alpha, mut beta := a, b
	mut depth := d
	old_alpha := a

	bot.search.nodes++	

	if (bot.search.nodes & 4095) > 0 {
		bot.search.check_time()
	}

	if depth <= 0 {
		return bot.board.score()
	}

	mut best_score := -9999999
	mut best_move := null_move

	found_entry := bot.search.tt.lookup(zobrist_key)

	if found_entry.key == zobrist_key && ply > 0 && found_entry.depth >= depth {
		if found_entry.type == .exact || 
		(found_entry.type == .upperbound && found_entry.score < alpha) ||
		(found_entry.type == .lowerbound && found_entry.score >= beta) {
			return found_entry.score
		}
	}

	mut moves := bot.board.get_moves(false)

	moves.sort_with_compare(fn [bot, ply, found_entry] (mv1 &Move, mv2 &Move) int {
		mv1_score := bot.guess_move_score(mv1, ply, found_entry)
		mv2_score := bot.guess_move_score(mv2, ply, found_entry)

		if mv1_score > mv2_score { return -1 }
		if mv1_score < mv2_score { return 1 }

		return 0
	})

	if bot.board.us_in_check() { depth++ }

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

		if bot.search.overtime { break }

		if alpha >= beta {
			if ply > 0 { bot.search.killers[ply] = move }
			break
		}
	}

	mut entry_flag := if best_score <= old_alpha { EntryType.upperbound } else if best_score >= beta { .lowerbound } else { .exact }

	if !bot.search.overtime {
		bot.search.tt.insert(TranspositionEntry{zobrist_key, best_score, depth, best_move, entry_flag})
	}

	return best_score
}