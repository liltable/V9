module engine

import chess
fn (mut bot Engine) handle_debug(mut args []string) {
	args.delete(0)

	match args[0] {
		'occbb' {
			bot.board.occupancies[chess.Occupancies.both].print()
		}
		'turn' {
			println(bot.board.turn)
		}
		'occopp' {
			bot.board.occupancies[bot.board.turn.opp()].print()
		}
		'occturn' {
			bot.board.occupancies[bot.board.turn].print()
		}
		'atkrook' {
			args.delete(0)

			if args[0] in chess.square_names.map(it.str()) {
				chess.rook_attacks(chess.square_names.map(it.str()).index(args[0]), bot.board.occupancies[chess.Occupancies.both]).print()
			}
		}
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
		'castle' {
			println('${bot.board.castling_rights:b}')
		}
		'castle_k' {
			println('${(bot.board.castling_rights & chess.our_kingside_right[bot.board.turn]):b}')
		}
		'castle_q' {
			println('${(bot.board.castling_rights & chess.our_queenside_right[bot.board.turn]):b}')
		}
		'zobrist' {
			println(bot.board.hash)
		}
		'info' {
			println('FEN: ${bot.board.get_fen()}')
			println('Hash: ${bot.board.hash}')
			println("Entry: ${bot.tt.lookup(bot.board.hash)}")
		}
		'decode-move' {
			move := args[1]

			if move.is_int() {
				decoded := unsafe { chess.Move(u32(move.int())) }
				println(decoded.lan())
			}
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
		'ttsize' {
			println('${bot.tt.size} entries using ${global_tt_size_mb}mb')
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
		'history' {
			println("${bot.board.history.map(it.lan())}")
			println("${bot.board.states.map(it.hash.str())}")
		}
		'eval' {
			println("Lazy Eval: ${bot.board.lazy_eval.score(bot.board.turn)}cp")
			println("Direct Eval: ${bot.board.score()}cp")
		}
		'draw' {
			println("50 Move Rule: ${bot.board.draw_counter >= 100}")
			println("Threefold Repetition: ${bot.board.is_repeated_position()}")
		}
		else {}
	}
}
