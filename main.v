module main

import engine

fn main() {
	mut bot := engine.Engine{}

	bot.uci_listen()
}
