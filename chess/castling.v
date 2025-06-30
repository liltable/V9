module chess

pub const all_castling_rights = u8(0xF) // u8(0b1111)
pub const no_castling_rights = u8(0x0) // u8 (0b0000)

pub const white_kingside_right = u8(8) // 0b1000
pub const white_queenside_right = u8(4) // 0b0100
pub const black_kingside_right = u8(2) // 0b0010
pub const black_queenside_right = u8(1) // 0b0001

pub const our_castling_rights = [no_castling_rights, (white_kingside_right | white_queenside_right),
	(black_kingside_right | black_queenside_right)]

pub const our_kingside_right = [no_castling_rights, white_kingside_right, black_kingside_right]
pub const our_queenside_right = [no_castling_rights, white_queenside_right, black_queenside_right]

pub const castling_symbols = ['K', 'Q', 'k', 'q']

pub const castling_flags = [white_kingside_right, white_queenside_right, black_kingside_right,
	black_queenside_right]

pub const kingside_destination = [-1, int(Square.g1), int(Square.g8)]
pub const queenside_destination = [-1, int(Square.c1), int(Square.c8)]

pub const queenside_rook_from = [-1, int(Square.a1), int(Square.a8)]
pub const kingside_rook_from = [-1, int(Square.h1), int(Square.h8)]
pub const queenside_rook_to = [-1, int(Square.d1), int(Square.d8)]
pub const kingside_rook_to = [-1, int(Square.f1), int(Square.f8)]

pub const king_homes = [-1, int(Square.e1), int(Square.e8)]

pub const queenside_no_attack = [Bitboard(0), 12, 864691128455135232]

pub enum CastleType {
	none
	kingside
	queenside
}
