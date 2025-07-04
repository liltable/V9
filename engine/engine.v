module engine

import chess
import log
import os

pub const max_depth = 32

pub struct Engine {
pub mut:
	info           EngineInfo
	board          chess.Board
	logger         log.Log
	search 		   Search
	stdin          chan string
	output         chan string
}

pub fn Engine.new() Engine {
	mut logger := log.Log{}

	logger.set_level(if '-debug' in os.args { .debug } else { .info })
	os.rm('./v9_debug.log') or { logger.warn("Couldn't delete the old logging file at startup.") }
	logger.set_output_path('./v9_debug.log')

	log.set_logger(&logger)

	return Engine{EngineInfo{}, chess.Board{}, &logger, Search{} chan string{}, chan string{}}
}

pub fn (mut bot Engine) log_input(input string) {
	bot.logger.debug("Received input: '${input}'")
}

pub fn (mut bot Engine) log_response(output string) {
	bot.logger.debug("Sent output: '${output}'")
	bot.logger.flush()
}

pub fn (mut bot Engine) uci_respond(output chan string) {
	for {
		response := <-output
		bot.log_response(response)
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

		bot.log_input(input)

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
				
			}
			'position' {
				bot.handle_pos(mut args)
			}
			'go' {
				bot.handle_go(mut args)
			}
			'print' {
				bot.board.print_stdout()
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
				log.warn("Received unknown command: '${command}'")
			}
		}
	}
}
