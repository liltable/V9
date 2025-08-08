module engine

import chess
fn (mut bot Engine) handle_debug(mut args []string) {
	args.delete(0)

	match args[0] {
		'pinned' {
			for bb in bot.board.pinned {
				bb.print()
			}
		}
		'check' {
			bot.board.checkray.print()
			println(bot.board.checkers)
		}
		'update' {
			bot.board.update_attacks()
		}
		'info' {
			bot.board.print()

			println('\nFEN: ${bot.board.get_fen()}')
			println('Hash: ${bot.board.hash}')
			println("Transposition Table Size: ${global_tt_size_mb}mb (${bot.tt.size} entries)")
			println("Side to Move: ${bot.board.turn}")
			println("Principal Variation: ${bot.search.pv.mainline()}")

			println("\n[EVALUATION]")
			println("Middlegame: (${bot.board.lazy_eval.mg[chess.Color.white]}, ${bot.board.lazy_eval.mg[chess.Color.black]})")
			println("Endgame: (${bot.board.lazy_eval.eg[chess.Color.white]}, ${bot.board.lazy_eval.eg[chess.Color.black]})")
			println("Gamephase: ${bot.board.lazy_eval.gamephase}")
			println("Static Eval: ${bot.board.lazy_eval.score(bot.board.turn)}cp")
			println("Entry: ${bot.tt.lookup(bot.board.hash)}")

			println("\n[DRAW DETECTION]")
			println("50 Move Rule: ${bot.board.draw_counter >= 100}")
			println("Threefold Repetition: ${bot.board.is_repeated_position()}")

			println("\n[GAME HISTORY]")
			println("${bot.board.history.map(it.lan())}")
			println("${bot.board.states.map(it.hash.str())}")

		}
		'undo' {
			bot.board.undo_move()
			bot.board.print()
		}
		'move' {
			args.delete(0)

			moves := bot.board.get_move_list()

			if args[0] in moves {
				bot.board.make_move(moves[args[0]])
				bot.board.print()
			}
		}
		'pv' {
			println("mainline: ${bot.search.pv.mainline()}")
			for l, line in bot.search.pv.line_lengths {
				if line > 0 {
					for idx in 0 .. line {
						move := bot.search.pv.lines[l][idx]
						if move != chess.null_move {
							print("${bot.search.pv.lines[l][idx].lan()} ")
							if idx == line - 1 {
								println("")
							}	
						}
					}
				}
			}
		}
		else {}
	}
}
