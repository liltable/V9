module engine

import chess
import log
import rand { element }

fn (mut bot Engine) handle_uci() {
	bot.output <- 'id name ${bot.info.name} v${bot.info.version}'
	bot.output <- 'id author ${bot.info.author}'
	bot.output <- 'uciok'
}

fn (mut bot Engine) handle_pos(mut args []string) {
	bot.board = chess.Board{}
	args.delete(0)

	postype := args[0]

	args.delete(0)

	if postype == 'startpos' {
		bot.board.load_fen(chess.starting_fen)
	} else if postype == 'kiwipete' {
		bot.board.load_fen(chess.kiwipete_fen)
	} else if postype == 'fen' {
		mut fen := ''

		for args.len > 0 && args[0] != 'moves' {
			fen += ' ${args[0]}'
			args.delete(0)
		}

		bot.board.load_fen(fen)
	}

	if args.len > 0 && args[0] == 'moves' {
		args.delete(0)

		for move in args {
			moves := bot.board.get_move_list()

			if move in moves {
				bot.board.make_move(moves[move])
			}
		}
	}
}

fn (mut bot Engine) handle_go(mut args []string) {
	args.delete(0)

	if args.len > 0 && args[0] == 'perft' {
		args.delete(0)

		depth := args[0]

		if depth.is_int() {
			bot.perft(depth.int())
		} else {
			log.warn("Invalid depth argument '${depth}' when asking for bot perft.")
		}
	} else {
		time_control := TimeControl.parse(mut args)
		time_limit := bot.choose_time_limit(time_control)

		bot.output <- 'info string time limit set to ${time_limit}ms'

		output := chan string{}

		bot.current_search = Search.new(bot.board, output, time_limit)

		go bot.start_search(mut &bot.current_search)

		for {
			result := <-bot.current_search.output or { ':(' }
			bot.output <- result

			if result.str().split_by_space()[0] == 'bestmove' {
				break
			}
		}
	}
}

pub fn (mut bot Engine) handle_quit() {
	if bot.current_search.active {
		bot.current_search.output <- 'stop'
	} else {
		exit(0)
	}
}

pub fn (mut bot Engine) random_move() chess.Move {
	moves := bot.board.get_moves(false)
	return element(moves) or { moves[0] }
}
