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

// stolen from Position::legal() in stockfish
pub fn (board Board) move_is_legal(move Move) bool {
	us := board.turn
	opp := us.opp()
	from := move.from_square()
	to := move.to_square()
	piece := move.piece()
	occupied := board.occupancies[Occupancies.both]

	our_king := board.bitboards[Bitboards.kings] & board.occupancies[us]

	assert piece.color() == us
	assert board.pieces[our_king.lsb()] == Piece.new(us, .king) 


	// [if en-passant] make sure en-passant is still valid and that we're not in check after making the move
	if move.special() == .en_passant {
		captured_square := square_bbs[to].forward(opp)
		occ_after_cap := (occupied ^ square_bbs[from] ^ captured_square) | square_bbs[to]

		assert (square_bbs[to] & board.en_passant_file) > 0
		assert piece == Piece.new(us, .pawn)
		assert board.pieces[captured_square.lsb()] == Piece.new(opp, .pawn)
		assert board.pieces[to] == null_piece

		return board.get_square_attackers(our_king.lsb(), occ_after_cap) == empty_bb
	}

	// [if castle] make sure the castle path is clear and free from attackers
	if move.castle() != .none {
		mut in_between := ray_attacks[from][to]

		if (in_between & occupied) > 0 { return false }

		for in_between > 0 {
			if board.get_square_attackers(in_between.pop_lsb(), occupied) > 0 { return false }
		}
	}

	// [if king] make sure the square we're moving to isn't attacked
	if board.pieces[from].type() == .king {
		return board.get_square_attackers(to, occupied ^ square_bbs[from]) == empty_bb
	}

	// [if none of the above] make sure we're not pinned, and if we are that we're moving along the pinray for the piece
	return (board.pinned[us] & square_bbs[from]) == empty_bb || (board.pinray[from] & square_bbs[to]) > 0
}
