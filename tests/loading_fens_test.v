module tests

import chess

fn test_loading_fens() {
	mut board := chess.Board{}

	board.load_fen(chess.starting_fen)

	assert board.get_fen() == chess.starting_fen

	board = chess.Board{}

	board.load_fen(chess.kiwipete_fen)

	assert board.get_fen() == chess.kiwipete_fen
}
