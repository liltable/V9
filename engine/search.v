module engine

import chess { Bitboard, Board, Color, Move }
import time { StopWatch }
import math { max }

const null_move = Move(0)
const empty_tt = TranspositionTable.new(0)

struct Search {
pub:
	time_limit int
pub mut:
	root_move Move
	output    chan string
	active    bool
mut:
	position Board
	timer    StopWatch
	tt       &TranspositionTable
	nodes    int
	overtime bool
}

pub fn Search.new(pos Board, oc chan string, time_limit int) Search {
	return Search{time_limit, null_move, &oc, false, pos, StopWatch{}, &empty_tt 0, false}
}

fn (mut search Search) check_overtime() {
	search.overtime = search.timer.elapsed().milliseconds() > search.time_limit
}

fn (search Search) get_zobrist_key() Bitboard {
	mut key := search.position.position_hash

	key ^= chess.zobrist.castling_keys[search.position.castling_rights]

	if search.position.en_passant_file > 0 {
		key ^= chess.zobrist.en_passant_keys[search.position.en_passant_file.lsb() & 7]
	}

	if search.position.turn == Color.black {
		key ^= chess.zobrist.side_key
	}

	return key
}

pub fn (mut search Search) quiesence(a int, b int) int {
	stand_pat := search.position.score()
	search.nodes++

	if (search.nodes & 2047) > 0 {
		search.check_overtime()
	}

	mut alpha, mut beta := a, b

	mut best_score := stand_pat

	if best_score >= beta {
		return best_score
	}

	alpha = max(alpha, best_score)

	for move in search.position.get_moves(true) {
		search.position.make_move(move)
		score := -search.quiesence(-beta, -alpha)
		search.position.undo_move()

		if score >= beta {
			return score
		}

		best_score = max(score, best_score)
		alpha = max(alpha, best_score)
	}

	return best_score
}

pub fn (mut search Search) negamax(depth int, ply int, a int, b int) int {
	search.nodes++

	mut best_score := -9999999
	mut alpha, mut beta := a, b

	if (search.nodes & 2047) > 0 {
		search.check_overtime()
	}

	if depth <= 2 {
		return search.quiesence(alpha, beta)
	}

	moves := search.position.get_moves(false)

	for move in moves {
		search.position.make_move(move)
		score := -search.negamax(depth - 1, ply + 1, -beta, -alpha)
		search.position.undo_move()

		if score > best_score {
			best_score = score
			alpha = max(alpha, best_score)

			if ply == 0 && !search.overtime {
				search.root_move = move
			}
		}

		if alpha >= beta || search.overtime {
			break
		}
	}

	if best_score == -9999999 {
		if search.position.us_in_check() {
			return -9999999 + ply
		}
	}

	return best_score
}

pub fn (mut bot Engine) start_search(mut search Search) {
	search.output <- 'info string starting search'

	search.timer = StopWatch{}
	search.nodes = 0
	search.overtime = false
	search.root_move = bot.random_move()
	search.tt = &bot.tt

	search.timer.start()

	search.iterate(search.output)
}

pub fn (mut search Search) iterate(output chan string) {
	mut depth := 2
	alpha, beta := -9999999, 9999999

	output <- 'info string search started'
	mut input := ''

	mut completed_searches := []Move{}

	for {
		score := search.negamax(depth, 0, alpha, beta)
		depth++

		search.check_overtime()
		input = ''
		output.try_pop(mut input)

		if search.overtime || input == 'stop' {
			break
		}

		completed_searches << search.root_move
		if search.root_move != null_move {
			output <- 'info depth ${depth} score cp ${score} nodes ${search.nodes} time ${search.timer.elapsed().milliseconds()} pv ${search.root_move.lan()}'
		}
	}

	output <- 'bestmove ${completed_searches.last().lan()}'
	search.timer.stop()
}
