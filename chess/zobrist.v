module chess

pub struct Zobrist {
pub:
	piece_keys      [13][64]Bitboard = [13][64]Bitboard{init: [64]Bitboard{init: xs32.roll()}}
	castling_keys   [16]Bitboard     = [16]Bitboard{init: xs32.roll()}
	en_passant_keys [8]Bitboard      = [8]Bitboard{init: xs32.roll()}
	side_key        Bitboard         = xs32.roll()
}

pub const zobrist = Zobrist{}

pub fn (z Zobrist) read_piece(piece Piece, square int) Bitboard {
	index := int(piece.type()) + if piece.color() == .white { 0 } else { 6 }

	return z.piece_keys[index][square]
}
