module main

import engine

fn main() {
	mut bot := engine.Engine.new()

	bot.uci_listen()
}
