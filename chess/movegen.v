module chess

pub fn (mut b Board) get_moves() []Move {
	b.update_attacks()

	mut moves := []Move{}

	if b.checkers > 1 {
		b.king_moves(mut &moves)
		return moves
	}

	b.pawn_moves(mut &moves)
	b.knight_moves(mut &moves)
	b.bishop_moves(mut &moves)
	b.rook_moves(mut &moves)
	b.queen_moves(mut &moves)
	b.king_moves(mut &moves)

	return moves
}

pub fn (mut b Board) get_move_list() map[string]Move {
	mut list := map[string]Move{}

	moves := b.get_moves()

	for mv in moves {
		list[mv.lan()] = mv
	}

	return list
}

pub fn (b Board) pawn_moves(mut moves []Move) {
	us := b.turn
	opp := us.opp()
	occupied := b.occupancies[Occupancies.both]
	enemy := b.occupancies[opp]
	empty := ~occupied
	our_pawns := b.bitboards[Bitboards.pawns] & b.occupancies[us]
	attacks := pawn_attacks[us]
	double_push_rank := if us == .white { rank_3 } else { rank_6 }
	promotion_rank := if us == .white { rank_7 } else { rank_2 }
	pinned := b.pinned[us]

	in_check := b.checkers > 0

	mut single_push_np := our_pawns & ~promotion_rank
	mut double_push := our_pawns
	mut captures_np := our_pawns & ~promotion_rank
	mut single_push_p := our_pawns & promotion_rank
	mut captures_p := our_pawns & promotion_rank

	for single_push_np > 0 {
		pawn := single_push_np.pop_lsb()
		piece := b.pieces[pawn]
		p := square_bbs[pawn]
		is_pinned := (square_bbs[pawn] & pinned) > 0

		mut destination := p.forward(us) & empty

		if in_check {
			destination &= b.checkray
		}

		if is_pinned {
			destination &= b.pinray[pawn]
		}

		for destination > 0 {
			moves << Move.encode(piece, pawn, destination.pop_lsb(), .none, .none, .none)
		}
	}

	for double_push > 0 {
		pawn := double_push.pop_lsb()
		piece := b.pieces[pawn]
		p := square_bbs[pawn]
		is_pinned := (pinned & square_bbs[pawn]) > 0

		mut destination := (p.forward(us) & double_push_rank & empty).forward(us) & empty

		if in_check {
			destination &= b.checkray
		}

		if is_pinned {
			destination &= b.pinray[pawn]
		}

		if destination > 0 {
			moves << Move.encode(piece, pawn, destination.lsb(), .none, .none, .pawn_double)
		}
	}

	for captures_np > 0 {
		pawn := captures_np.pop_lsb()
		piece := b.pieces[pawn]
		is_pinned := (pinned & square_bbs[pawn]) > 0

		mut targets := attacks[pawn] & enemy
		mut capture_ep := attacks[pawn] & b.en_passant_file & b.pinray[pawn] & empty

		if in_check {
			targets &= b.checkray
			capture_ep &= b.checkray
		}

		if is_pinned {
			pinray := b.pinray[pawn]

			targets &= pinray
			capture_ep &= pinray
		}

		for targets > 0 {
			moves << Move.encode(piece, pawn, targets.pop_lsb(), .none, .none, .capture)
		}

		for capture_ep > 0 {
			destination := capture_ep.pop_lsb()
			target := square_bbs[destination].forward(opp).lsb()

			if b.pieces[target] == Piece.new(opp, .pawn) {
				moves << Move.encode(piece, pawn, destination, .none, .none, .en_passant)
			}
		}
	}

	for single_push_p > 0 {
		pawn := single_push_p.pop_lsb()
		piece := b.pieces[pawn]
		is_pinned := (b.pinned[us] & square_bbs[pawn]) > 0

		mut destination := square_bbs[pawn].forward(us) & empty & b.pinray[pawn]

		if in_check {
			destination &= b.checkray
		}

		if is_pinned {
			destination &= b.pinray[pawn]
		}

		if destination > 0 {
			moves << Move.encode(piece, pawn, destination.lsb(), .knight, .none, .none)
			moves << Move.encode(piece, pawn, destination.lsb(), .bishop, .none, .none)
			moves << Move.encode(piece, pawn, destination.lsb(), .rook, .none, .none)
			moves << Move.encode(piece, pawn, destination.lsb(), .queen, .none, .none)
		}
	}

	for captures_p > 0 {
		pawn := captures_p.pop_lsb()
		piece := b.pieces[pawn]
		is_pinned := (b.pinned[us] & square_bbs[pawn]) > 0

		mut targets := attacks[square_bbs[pawn].lsb()] & enemy

		if in_check {
			targets &= b.checkray
		}

		if is_pinned {
			targets &= b.pinray[pawn]
		}

		for targets > 0 {
			moves << Move.encode(piece, pawn, targets.lsb(), .knight, .none, .capture)
			moves << Move.encode(piece, pawn, targets.lsb(), .bishop, .none, .capture)
			moves << Move.encode(piece, pawn, targets.lsb(), .rook, .none, .capture)
			moves << Move.encode(piece, pawn, targets.lsb(), .queen, .none, .capture)

			targets.pop_lsb()
		}
	}
}

pub fn (b Board) knight_moves(mut moves []Move) {
	us := b.turn
	enemy := b.occupancies[us.opp()]
	empty := ~b.occupancies[Occupancies.both]
	in_check := b.checkers > 0

	// Pinned knights can't move, so no fancy pinned piece handling

	mut knights := b.bitboards[Bitboards.knights] & b.occupancies[us] & ~b.pinned[us]

	for knights > 0 {
		knight := knights.pop_lsb()
		piece := b.pieces[knight]
		attacks := knight_attacks[knight]

		mut captures := attacks & enemy
		mut quiets := attacks & empty

		if in_check {
			captures &= b.checkray
			quiets &= b.checkray
		}

		for quiets > 0 {
			moves << Move.encode(piece, knight, quiets.pop_lsb(), .none, .none, .none)
		}

		for captures > 0 {
			moves << Move.encode(piece, knight, captures.pop_lsb(), .none, .none, .capture)
		}
	}
}

pub fn (b Board) bishop_moves(mut moves []Move) {
	us := b.turn
	enemy := b.occupancies[us.opp()]
	occupied := b.occupancies[Occupancies.both]
	empty := ~occupied
	in_check := b.checkers > 0

	mut bishops := b.bitboards[Bitboards.bishops] & b.occupancies[us]

	for bishops > 0 {
		bishop := bishops.pop_lsb()
		piece := b.pieces[bishop]
		attacks := bishop_attacks(bishop, occupied)
		is_pinned := (b.pinned[us] & square_bbs[bishop]) > 0

		mut captures := attacks & enemy
		mut quiets := attacks & empty

		if in_check {
			captures &= b.checkray
			quiets &= b.checkray
		}

		if is_pinned {
			pinray := b.pinray[bishop]

			captures &= pinray
			quiets &= pinray
		}

		for quiets > 0 {
			moves << Move.encode(piece, bishop, quiets.pop_lsb(), .none, .none, .none)
		}

		for captures > 0 {
			moves << Move.encode(piece, bishop, captures.pop_lsb(), .none, .none, .capture)
		}
	}
}

pub fn (b Board) rook_moves(mut moves []Move) {
	us := b.turn
	enemy := b.occupancies[us.opp()]
	occupied := b.occupancies[Occupancies.both]
	empty := ~occupied
	is_check := b.checkers > 0

	mut rooks := b.bitboards[Bitboards.rooks] & b.occupancies[us]

	for rooks > 0 {
		rook := rooks.pop_lsb()
		piece := b.pieces[rook]
		attacks := rook_attacks(rook, occupied)
		is_pinned := (square_bbs[rook] & b.pinned[us]) > 0

		mut captures := attacks & enemy
		mut quiets := attacks & empty

		if is_check {
			captures &= b.checkray
			quiets &= b.checkray
		}

		if is_pinned {
			pinray := b.pinray[rook]

			captures &= pinray
			quiets &= pinray
		}

		for quiets > 0 {
			moves << Move.encode(piece, rook, quiets.pop_lsb(), .none, .none, .none)
		}

		for captures > 0 {
			moves << Move.encode(piece, rook, captures.pop_lsb(), .none, .none, .capture)
		}
	}
}

pub fn (b Board) queen_moves(mut moves []Move) {
	us := b.turn
	enemy := b.occupancies[us.opp()]
	occupied := b.occupancies[Occupancies.both]
	empty := ~occupied
	in_check := b.checkers > 0

	mut queens := b.bitboards[Bitboards.queens] & b.occupancies[us]

	for queens > 0 {
		queen := queens.pop_lsb()
		piece := b.pieces[queen]
		attacks := queen_attacks(queen, occupied)
		is_pinned := (square_bbs[queen] & b.pinned[us]) > 0

		mut captures := attacks & enemy
		mut quiets := attacks & empty

		if in_check {
			captures &= b.checkray
			quiets &= b.checkray
		}

		if is_pinned {
			pinray := b.pinray[queen]

			captures &= pinray
			quiets &= pinray
		}

		for quiets > 0 {
			moves << Move.encode(piece, queen, quiets.pop_lsb(), .none, .none, .none)
		}

		for captures > 0 {
			moves << Move.encode(piece, queen, captures.pop_lsb(), .none, .none, .capture)
		}
	}
}

pub fn (b Board) king_moves(mut moves []Move) {
	us := b.turn
	enemy := b.occupancies[us.opp()]
	friendly := b.occupancies[us]
	our_king := b.bitboards[Bitboards.kings] & b.occupancies[us]
	occupied := b.occupancies[Occupancies.both] & ~our_king
	empty := ~occupied
	k := our_king.lsb()
	king := b.pieces[k]
	at_home := k in king_homes
	in_check := b.checkers > 0

	mut evasions := king_attacks[k] & empty
	mut captures := king_attacks[k] & enemy

	for evasions > 0 {
		destination := evasions.pop_lsb()

		if b.get_square_attackers(destination, occupied) == empty_bb {
			moves << Move.encode(king, k, destination, .none, .none, .none)
		}
	}

	for captures > 0 {
		target := captures.pop_lsb()

		if b.get_square_attackers(target, occupied) == empty_bb {
			moves << Move.encode(king, k, target, .none, .none, .capture)
		}
	}

	if at_home && (our_castling_rights[us] & b.castling_rights) > 0 && !in_check {
		mut castling_rooks := b.bitboards[Bitboards.rooks] & friendly & four_corners & all_ranks[k >> 3]

		for castling_rooks > 0 {
			rook := castling_rooks.pop_lsb()
			mut in_between := ray_attacks[rook][k]

			mut eligible := true

			if (in_between & occupied) > 0 {
				eligible = false
			}

			if (square_bbs[rook] & file_a) > 0 {
				in_between = queenside_no_attack[us]
			}

			for in_between > 0 {
				sq := in_between.pop_lsb()

				if b.get_square_attackers(sq, occupied) > 0 {
					eligible = false
				}
			}

			if eligible {
				match rook {
					kingside_rook_from[us] {
						if (b.castling_rights & our_kingside_right[us]) > 0 {
							moves << Move.encode(king, k, kingside_destination[us], .none,
								.kingside, .none)
						}
					}
					queenside_rook_from[us] {
						if (b.castling_rights & our_queenside_right[us]) > 0 {
							moves << Move.encode(king, k, queenside_destination[us], .none,
								.queenside, .none)
						}
					}
					else {}
				}
			}
		}
	}
}
