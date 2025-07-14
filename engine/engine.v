module engine

import chess
import os

pub const max_depth = 32

pub struct Engine {
pub mut:
	info           EngineInfo
	board          chess.Board
	search 		   Search
	tt 				TranspositionTable
	stdin          chan string
	output         chan string
}

pub fn (mut bot Engine) uci_respond(output chan string) {
	for {
		response := <-output
		println(response)
	}
}

pub fn (mut bot Engine) read_stdin(stdin chan string) {
	for {
		input := os.get_line()
		stdin <- input.trim_space()
	}
}

pub fn (mut bot Engine) uci_listen() {
	println('${bot.info.name} ${bot.info.version} by ${bot.info.author}')
	bot.board.load_fen(chess.starting_fen)
	spawn bot.read_stdin(bot.stdin)
	spawn bot.uci_respond(bot.output)

	for {
		input := <-bot.stdin or { '' }

		mut args := input.split_by_space()
		mut command := if args.len > 0 { args[0] } else { input }

		match command.to_lower() {
			'uci' {
				bot.handle_uci()
			}
			'isready' {
				bot.output <- 'readyok'
			}
			'ucinewgame' {
				bot.board = chess.Board{}
				bot.board.load_fen(chess.starting_fen)
				bot.search = Search{}
			}
			'position' {
				bot.handle_pos(mut args)
			}
			'go' {
				bot.handle_go(mut args)
			}
			'print' {
				bot.board.print()
			}
			'debug' {
				bot.handle_debug(mut args)
			}
			'quit' {
				bot.handle_quit()
			}
			'exit' {
				bot.handle_quit()
			}
			'stop' {
				if bot.search.active {
					bot.search.comms <- 'stop'
				}
			}
			else {
				// println("Received unknown command: '${command}'")
				// do nothing
			}
		}
	}
}
