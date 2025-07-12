module chess

pub fn (board Board) pawn_captures(mut list MoveList) {
	us := board.turn
	opp := us.opp()
	enemy := board.occupancies[opp]
	our_pawns := board.bitboards[Bitboards.pawns] & board.occupancies[us]
	attacks := pawn_attacks[us]
	promotion_rank := if us == .white { rank_7 } else { rank_2 }
	pinned := board.pinned[us]

	in_check := board.checkers > 0

	mut captures_np := our_pawns & ~promotion_rank
	mut captures_p := our_pawns & promotion_rank

	for captures_np > 0 {
		pawn := captures_np.pop_lsb()
		piece := board.pieces[pawn]
		is_pinned := (pinned & square_bbs[pawn]) > 0

		mut targets := attacks[pawn] & enemy
		mut capture_ep := attacks[pawn] & board.en_passant_file

		if in_check {
			targets &= board.checkray
			capture_ep &= board.checkray
		}

		if is_pinned {
			pinray := board.pinray[pawn]

			targets &= pinray
			capture_ep &= pinray
		}

		for targets > 0 {
			list.add_move(Move.encode(piece, pawn, targets.pop_lsb(), .none, .none, .capture))
		}

		for capture_ep > 0 {
			destination := capture_ep.pop_lsb()
			target := square_bbs[destination].forward(opp).lsb()

			if board.pieces[target] == Piece.new(opp, .pawn) {
				list.add_move(Move.encode(piece, pawn, destination, .none, .none, .en_passant))
			}
		}
	}

	for captures_p > 0 {
		pawn := captures_p.pop_lsb()
		piece := board.pieces[pawn]
		is_pinned := (board.pinned[us] & square_bbs[pawn]) > 0

		mut targets := attacks[square_bbs[pawn].lsb()] & enemy

		if in_check {
			targets &= board.checkray
		}

		if is_pinned {
			targets &= board.pinray[pawn]
		}

		for targets > 0 {
			list.add_move(Move.encode(piece, pawn, targets.lsb(), .knight, .none, .capture))
			list.add_move(Move.encode(piece, pawn, targets.lsb(), .bishop, .none, .capture))
			list.add_move(Move.encode(piece, pawn, targets.lsb(), .rook, .none, .capture))
			list.add_move(Move.encode(piece, pawn, targets.lsb(), .queen, .none, .capture))

			targets.pop_lsb()
		}
	}
} 

pub fn (board Board) knight_captures(mut list MoveList) {
	us := board.turn
	enemy := board.occupancies[us.opp()]
	in_check := board.checkers > 0

	// Pinned knights can't move, so no fancy pinned piece handling

	mut knights := board.bitboards[Bitboards.knights] & board.occupancies[us] & ~board.pinned[us]

	for knights > 0 {
		knight := knights.pop_lsb()
		piece := board.pieces[knight]
		attacks := knight_attacks[knight]

		mut captures := attacks & enemy

		if in_check {
			captures &= board.checkray
		}

		for captures > 0 {
			list.add_move(Move.encode(piece, knight, captures.pop_lsb(), .none, .none, .capture))
		}
	}
}

pub fn (board Board) bishop_captures(mut list MoveList) {
	us := board.turn
	occupied := board.occupancies[Occupancies.both]
	enemy := board.occupancies[us.opp()]
	in_check := board.checkers > 0

	mut bishops := board.bitboards[Bitboards.bishops] & board.occupancies[us]

	for bishops > 0 {
		bishop := bishops.pop_lsb()
		piece := board.pieces[bishop]
		attacks := fast_bishop_moves(bishop, occupied)
		is_pinned := (board.pinned[us] & square_bbs[bishop]) > 0

		mut captures := attacks & enemy 
		
		if in_check {
			captures &= board.checkray
		}

		if is_pinned {
			captures &= board.pinray[bishop]
		}

		for captures > 0 {
			list.add_move(Move.encode(piece, bishop, captures.pop_lsb(), .none, .none, .capture))
		}
	}
}

pub fn (board Board) rook_captures(mut list MoveList) {
	us := board.turn
	enemy := board.occupancies[us.opp()]
	occupied := board.occupancies[Occupancies.both]
	in_check := board.checkers > 0

	mut rooks := board.bitboards[Bitboards.rooks] & board.occupancies[us]

	for rooks > 0 {
		rook := rooks.pop_lsb()
		piece := board.pieces[rook]
		attacks := fast_rook_moves(rook, occupied)
		is_pinned := (square_bbs[rook] & board.pinned[us]) > 0

		mut captures := attacks & enemy

		if in_check {
			captures &= board.checkray
		}
		
		if is_pinned {
			captures &= board.pinray[rook]
		}

		for captures > 0 {
			list.add_move(Move.encode(piece, rook, captures.pop_lsb(), .none, .none, .capture))
		}
	}
}

pub fn (board Board) queen_captures(mut list MoveList) {
	us := board.turn
	enemy := board.occupancies[us.opp()]
	occupied := board.occupancies[Occupancies.both]
	in_check := board.checkers > 0 

	mut queens := board.bitboards[Bitboards.queens] & board.occupancies[us]

	for queens > 0 {
		queen := queens.pop_lsb()
		piece := board.pieces[queen]
		attacks := fast_queen_moves(queen, occupied)
		is_pinned := (square_bbs[queen] & board.pinned[us]) > 0 

		mut captures := attacks & enemy
		
		if in_check {
			captures &= board.checkray
		}

		if is_pinned {
			captures &= board.pinray[queen]
		}

		for captures > 0 {
			list.add_move(Move.encode(piece, queen, captures.pop_lsb(), .none, .none, .capture))
		}
	}
}