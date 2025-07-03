module engine

import chess

fn (mut bot Engine) handle_debug(mut args []string) {
	args.delete(0)

	match args[0] {
		'occbb' {
			bot.board.occupancies[chess.Occupancies.both].print_stdout()
		}
		'turn' {
			println(bot.board.turn)
		}
		'occopp' {
			bot.board.occupancies[bot.board.turn.opp()].print_stdout()
		}
		'occturn' {
			bot.board.occupancies[bot.board.turn].print_stdout()
		}
		'atkrook' {
			args.delete(0)

			if args[0] in chess.square_names.map(it.str()) {
				chess.rook_attacks(chess.square_names.map(it.str()).index(args[0]), bot.board.occupancies[chess.Occupancies.both]).print_stdout()
			}
		}
		'pinned' {
			for bb in bot.board.pinned {
				bb.print_stdout()
			}
		}
		'check' {
			bot.board.checkray.print_stdout()
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
			println(bot.board.position_hash)
		}
		'info' {
			println('FEN: ${bot.board.get_fen()}')
			println('Hash: ${bot.board.position_hash}')
		}
		'undo' {
			bot.board.undo_move()
			bot.board.print_stdout()
		}
		'move' {
			args.delete(0)

			moves := bot.board.get_move_list()

			if args[0] in moves {
				bot.board.make_move(moves[args[0]])
				bot.board.print_stdout()
			}
		}
		'ttsize' {
			println('${bot.search.tt.size} entries')
		}
		else {}
	}
}
