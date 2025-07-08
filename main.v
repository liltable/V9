module main

import engine
import chess

fn main() {
	mut bot := engine.Engine.new()

	bot.uci_listen()

	// chess.print_magics(chess.Slider.bishop)
}
