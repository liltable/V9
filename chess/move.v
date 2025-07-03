module chess

// move flags => castle_k, castle_q, capture, en_passant, all promotion types [4]

pub enum SpecialType {
	none
	capture
	en_passant  = 3
	pawn_double = 4
}

pub type Move = u32

pub const null_move = Move(0)
/*
MOVE ENCODING

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # total 32 bits
# # # # # # # # moving piece (8 bits)
# # # # # #     from square (6 bits) >> 8
# # # # # #     to square (6 bits) >> 14
# # #           promotions (3 bits) >> 20
# #             castling (2 bits) >> 23
# #             capture, en-passant & pawn double (3 bits) >> 25

*/

pub const move_piece_mask = Move(0xFF) // 8 bits - 0x11111111 (one 1 for every bit)
pub const move_from_mask = Move(0x3F) << 8 // 6 bits
pub const move_to_mask = Move(0x3F) << 14 // 6 bits
pub const move_promo_mask = Move(0x7) << 20 // 3 set bits for 4 promotion types
pub const move_castling_mask = Move(0x3) << 23 // 2 set bits for castling
pub const move_special_mask = Move(0x7) << 25 // 3 set bits for capture, en-passant, and pawn double

pub fn Move.encode(piece Piece, from int, to int, promotion Piecetype, castling CastleType, special SpecialType) Move {
	return Move(u32(piece) | u32(from) << 8 | u32(to) << 14 | u32(promotion) << 20 | u32(castling) << 23 | u32(special) << 25)
}

pub fn (m Move) from_square() int {
	return (m & move_from_mask) >> 8
}

pub fn (m Move) to_square() int {
	return (m & move_to_mask) >> 14
}

pub fn (m Move) piece() Piece {
	unsafe {
		return Piece(m & move_piece_mask)
	}
}

pub fn (m Move) promotion() Piecetype {
	unsafe {
		return Piecetype((m & move_promo_mask) >> 20)
	}
}

pub fn (m Move) castle() CastleType {
	unsafe {
		return CastleType((m & move_castling_mask) >> 23)
	}
}

pub fn (m Move) special() SpecialType {
	unsafe {
		return SpecialType((m & move_special_mask) >> 25)
	}
}

pub fn (m Move) is_capture() bool {
	special := m.special()
	return special != .none && special != .pawn_double
}

pub fn (m Move) lan() string {
	return '${square_names[m.from_square()]}${square_names[m.to_square()]}${piecetype_symbols[(m & move_promo_mask) >> 20]}'
}
