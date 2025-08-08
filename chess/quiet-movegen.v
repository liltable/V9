module chess

pub enum MovegenType {
	quiets
	captures
	all
}

pub fn (mut b Board) get_moves(type MovegenType) MoveList {
	b.update_attacks()

	mut list := MoveList{}

	if b.checkers > 1 {
		b.king_moves(mut &list)
		return list
	}

	match type {
		.quiets {
			b.pawn_quiets(mut &list)
			b.knight_quiets(mut &list)
			b.bishop_quiets(mut &list)
			b.rook_quiets(mut &list)
			b.queen_quiets(mut &list)
			
			b.king_moves(mut &list)
		}
		.captures {
			b.pawn_captures(mut &list)
			b.pawn_promotions(mut &list)
			b.knight_captures(mut &list)
			b.bishop_captures(mut &list)
			b.rook_captures(mut &list)
			b.queen_captures(mut &list)
		}
		.all {
			b.pawn_quiets(mut &list)
			b.pawn_promotions(mut &list)
			b.pawn_captures(mut &list)

			b.knight_quiets(mut &list)
			b.knight_captures(mut &list)

			b.bishop_quiets(mut &list)
			b.bishop_captures(mut &list)

			b.rook_quiets(mut &list)
			b.rook_captures(mut &list)

			b.queen_quiets(mut &list)
			b.queen_captures(mut &list)

			b.king_moves(mut &list)
		}
	}

	return list
}

pub fn (mut b Board) get_move_list() map[string]Move {
	mut list := map[string]Move{}

	move_list := b.get_moves(.all)

	for idx in 0 .. move_list.count {
		move := move_list.moves[idx]

		if move != null_move {
			list[move.lan()] = move
		}
	}

	return list
}

pub fn (b Board) pawn_quiets(mut list MoveList) {
	us := b.turn
	occupied := b.occupancies[Occupancies.both]
	empty := ~occupied
	our_pawns := b.bitboards[Bitboards.pawns] & b.occupancies[us]
	double_push_rank := if us == .white { rank_3 } else { rank_6 }
	promotion_rank := if us == .white { rank_7 } else { rank_2 }
	pinned := b.pinned[us]

	in_check := b.checkers > 0

	mut single_push_np := our_pawns & ~promotion_rank
	mut double_push := our_pawns

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
			list.add_move(Move.quiet(piece, pawn, destination.pop_lsb()))
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
			list.add_move(Move.pawn_double(piece, pawn, destination.pop_lsb()))
		}
	}
}

pub fn (b Board) knight_quiets(mut list MoveList) {
	us := b.turn
	empty := ~b.occupancies[Occupancies.both]
	in_check := b.checkers > 0

	// Pinned knights can't move, so no fancy pinned piece handling
	mut knights := b.bitboards[Bitboards.knights] & b.occupancies[us] & ~b.pinned[us]

	for knights > 0 {
		knight := knights.pop_lsb()
		piece := b.pieces[knight]
		attacks := knight_attacks[knight]

		mut quiets := attacks & empty

		if in_check {
			quiets &= b.checkray
		}

		for quiets > 0 {
			list.add_move(Move.quiet(piece, knight, quiets.pop_lsb()))
		}
	}
}

pub fn (b Board) bishop_quiets(mut list MoveList) {
	us := b.turn
	occupied := b.occupancies[Occupancies.both]
	empty := ~occupied
	in_check := b.checkers > 0

	mut bishops := b.bitboards[Bitboards.bishops] & b.occupancies[us]

	for bishops > 0 {
		bishop := bishops.pop_lsb()
		piece := b.pieces[bishop]
		attacks := fast_bishop_moves(bishop, occupied)
		is_pinned := (b.pinned[us] & square_bbs[bishop]) > 0

		mut quiets := attacks & empty

		if in_check {
			quiets &= b.checkray
		}

		if is_pinned {
			quiets &= b.pinray[bishop]
		}

		for quiets > 0 {
			list.add_move(Move.quiet(piece, bishop, quiets.pop_lsb()))
		}

	}
}

pub fn (b Board) rook_quiets(mut list MoveList) {
	us := b.turn
	occupied := b.occupancies[Occupancies.both]
	empty := ~occupied
	is_check := b.checkers > 0

	mut rooks := b.bitboards[Bitboards.rooks] & b.occupancies[us]

	for rooks > 0 {
		rook := rooks.pop_lsb()
		piece := b.pieces[rook]
		attacks := fast_rook_moves(rook, occupied)
		is_pinned := (square_bbs[rook] & b.pinned[us]) > 0
		
		mut quiets := attacks & empty

		if is_check {
			quiets &= b.checkray
		}

		if is_pinned {
			quiets &= b.pinray[rook]
		}

		for quiets > 0 {
			list.add_move(Move.quiet(piece, rook, quiets.pop_lsb()))
		}
	}
}

pub fn (b Board) queen_quiets(mut list MoveList) {
	us := b.turn
	occupied := b.occupancies[Occupancies.both]
	empty := ~occupied
	in_check := b.checkers > 0

	mut queens := b.bitboards[Bitboards.queens] & b.occupancies[us]

	for queens > 0 {
		queen := queens.pop_lsb()
		piece := b.pieces[queen]
		attacks := fast_queen_moves(queen, occupied)
		is_pinned := (square_bbs[queen] & b.pinned[us]) > 0

		mut quiets := attacks & empty

		if in_check {
			quiets &= b.checkray
		}

		if is_pinned {
			quiets &= b.pinray[queen]
		}

		for quiets > 0 {
			list.add_move(Move.quiet(piece, queen, quiets.pop_lsb()))
		}
	}
}

pub fn (b Board) king_moves(mut list MoveList) {
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
			list.add_move(Move.quiet(king, k, destination))
		}
	}

	for captures > 0 {
		target := captures.pop_lsb()
		target_type := b.pieces[target].type()

		if b.get_square_attackers(target, occupied) == empty_bb {
			list.add_move(Move.capture(king, target_type, k, target))
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
							list.add_move(Move.castle(king, k, kingside_destination[us]))
						}
					}
					queenside_rook_from[us] {
						if (b.castling_rights & our_queenside_right[us]) > 0 {
							list.add_move(Move.castle(king, k, queenside_destination[us]))
						}
					}
					else {}
				}
			}
		}
	}
}
