module chess

pub type Move = u32
pub const null_move = Move(0)

/* MOVE ENCODING v2 

Use this move encoding strategy for better support when move sorting.

My hypothesis is that scoring and sorting the moves is currently slowing the engine
down just enough to lose ~10 elo, and that might have to do
with the fact that I'm checking the board for the captured piece type.

We can write static methods for each move type for move encoding and use those instead for readability.
- quiet
- capture
- en-passant
- promotion
- capture-promotion
- pawn double-push
- castle

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # total 32 bits
# # # # # # # # moving piece (8 bits)
# # # # # #     from square (6 bits) >> 8
# # # # # #     to square (6 bits) >> 14
# # #           promotions (3 bits) >> 20
#              	is_castle (1 bit) >> 21
# # # 			capture_type (3 bits) >> 22
# 				is_en_passant (1 bit) >> 25
# 				is_pawn_double (1 bit) >> 26

*/

pub const move_piece_mask = Move(0xFF) // 8 bits for the sizeof(Piece)
pub const move_from_mask = Move(0x3F) << 8 // 6 bits
pub const move_to_mask = Move(0x3F) << 14 // 6 bits
pub const move_promo_mask = Move(0x7) << 20 // 3 set bits for 4 promotion types
pub const move_castling_mask = Move(0x1) << 23 // 1 bit for is castle
pub const move_captured_mask := Move(0x7) << 24 // 3 bits for 5 capturable types
pub const move_passant_mask := Move(0x1) << 27
pub const move_double_mask := Move(0x1) << 28

// v fmt off
pub fn Move.encode(
	piece Piece,
	from int,
	to int,
	captured Piecetype,
	promotion Piecetype,
	is_castle bool,
	is_en_passant bool,
	is_pawn_double bool

) Move {
	return Move(u32(piece) | u32(from) << 8 | u32(to) << 14 | u32(promotion) << 20 | if is_castle { move_castling_mask } else { null_move } | u32(captured) << 24 | if is_en_passant { move_passant_mask } else { null_move } | if is_pawn_double { move_double_mask } else { null_move } )
}

// v fmt on

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

pub fn (m Move) captured() Piecetype {
	unsafe {
		return Piecetype((m & move_captured_mask) >> 24)
	}
}

pub fn (m Move) is_castle() bool {
	return m & move_castling_mask > 0
}


pub fn (m Move) is_en_passant() bool {
	return m & move_passant_mask > 0
}

pub fn (m Move) is_pawn_double() bool {
	return m & move_double_mask > 0
}

pub fn (m Move) lan() string {
	return '${square_names[m.from_square()]}${square_names[m.to_square()]}${piecetype_symbols[(m & move_promo_mask) >> 20]}'
}

pub fn Move.quiet(piece Piece, from int, to int) Move {
	return Move.encode(piece, from, to, .none, .none, false, false, false)
}

pub fn Move.pawn_double(piece Piece, from int, to int) Move {
	return Move.encode(piece, from, to, .none, .none, false, false, true)
}

pub fn Move.capture(piece Piece, captured Piecetype, from int, to int) Move {
	return Move.encode(piece, from, to, captured, .none, false, false, false)
}

pub fn Move.promotion(piece Piece, promoted Piecetype, from int, to int) Move {
	return Move.encode(piece, from, to, .none, promoted, false, false, false)
}

pub fn Move.castle(piece Piece, from int, to int) Move {
	return Move.encode(piece, from, to, .none, .none, true, false, false)
}

pub fn Move.capture_promotion(piece Piece, captured Piecetype, promoted Piecetype, from int, to int) Move {
	return Move.encode(piece, from, to, captured, promoted, false, false, false)
}

pub fn Move.en_passant(piece Piece, from int, to int) Move {
	return Move.encode(piece, from, to, .pawn, .none, false, true, false)
}

// stolen from Position::legal() in stockfish
// pub fn (board Board) move_is_legal(move Move) bool {
// 	us := board.turn
// 	opp := us.opp()
// 	from := move.from_square()
// 	to := move.to_square()
// 	piece := move.piece()
// 	occupied := board.occupancies[Occupancies.both]

// 	our_king := board.bitboards[Bitboards.kings] & board.occupancies[us]

// 	assert piece.color() == us
// 	assert board.pieces[our_king.lsb()] == Piece.new(us, .king) 


// 	// [if en-passant] make sure en-passant is still valid and that we're not in check after making the move
// 	if move.special() == .en_passant {
// 		captured_square := square_bbs[to].forward(opp)
// 		occ_after_cap := (occupied ^ square_bbs[from] ^ captured_square) | square_bbs[to]

// 		assert (square_bbs[to] & board.en_passant_file) > 0
// 		assert piece == Piece.new(us, .pawn)
// 		assert board.pieces[captured_square.lsb()] == Piece.new(opp, .pawn)
// 		assert board.pieces[to] == null_piece

// 		return board.get_square_attackers(our_king.lsb(), occ_after_cap) == empty_bb
// 	}

// 	// [if castle] make sure the castle path is clear and free from attackers
// 	if move.castle() != .none {
// 		mut in_between := ray_attacks[from][to]

// 		if (in_between & occupied) > 0 { return false }

// 		for in_between > 0 {
// 			if board.get_square_attackers(in_between.pop_lsb(), occupied) > 0 { return false }
// 		}
// 	}

// 	// [if king] make sure the square we're moving to isn't attacked
// 	if board.pieces[from].type() == .king {
// 		return board.get_square_attackers(to, occupied ^ square_bbs[from]) == empty_bb
// 	}

// 	// [if none of the above] make sure we're not pinned, and if we are that we're moving along the pinray for the piece
// 	return (board.pinned[us] & square_bbs[from]) == empty_bb || (board.pinray[from] & square_bbs[to]) > 0
// }
