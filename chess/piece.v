module chess

pub enum Color {
	none
	white
	black
}

pub fn (c Color) opp() Color {
	if c == .white {
		return .black
	} else {
		return .white
	}
}

pub enum Piecetype {
	none
	pawn
	knight
	bishop
	rook
	queen
	king
}

pub fn (piece Piece) get_attacks(sq int, blockers Bitboard) Bitboard {
	mut attacks := empty_bb

	kind := piece.type()
	side := piece.color()

	match kind {
		.pawn {
			attacks |= pawn_attacks[side][sq]
		}
		.knight {
			attacks |= knight_attacks[sq]
		}
		.bishop {
			attacks |= fast_bishop_moves(sq, blockers)
		}
		.rook {
			attacks |= fast_rook_moves(sq, blockers)
		}
		.queen {
			attacks |= fast_queen_moves(sq, blockers)
		}
		.king {
			attacks |= king_attacks[sq]
		}
		else {}
	}

	return attacks
}

pub const piecetype_symbols = ['', 'p', 'n', 'b', 'r', 'q', 'k']
pub const color_symbols = ['', 'w', 'b']

pub const symbol_to_piecetype = {
	'':  Piecetype.none
	'p': .pawn
	'n': .knight
	'b': .bishop
	'r': .rook
	'q': .queen
	'k': .king
}

pub const symbol_to_color = {
	'':  Color.none
	'w': .white
	'b': .black
}

const color_mask = Piece(0b00011)
const piecetype_mask = Piece(0b11100)

pub type Piece = u8

pub fn Piece.new(color Color, type Piecetype) Piece {
	return Piece(u8(color) | u8(type) << 2)
}

pub fn (p Piece) color() Color {
	unsafe {
		return Color(p & color_mask)
	}
}

pub fn (p Piece) type() Piecetype {
	unsafe {
		return Piecetype((p & piecetype_mask) >> 2)
	}
}

pub fn (p Piece) symbol() string {
	symbol := piecetype_symbols[int(p.type())]

	return if p.color() == .white { symbol.to_upper() } else { symbol }
}

pub const null_piece = Piece(0)
