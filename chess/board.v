module chess

pub const starting_fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
pub const kiwipete_fen = 'r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1'
pub const qpo_chigorin_fen = 'r1bqkbnr/ppp2ppp/2n1p3/3p4/2PP4/4PN2/PP3PPP/RNBQKB1R b KQkq c3 0 4'

pub struct StateHistory {
pub:
	captured        Piecetype
	halfmoves       int
	en_passant_file Bitboard
	castling_rights u8
}

pub struct Board {
pub mut:
	pieces          [64]Piece
	bitboards       [7]Bitboard // none, p, n, b, r, q, k
	occupancies     [3]Bitboard // both, w, b
	pinned          [3]Bitboard // none, w, b
	pinray          [64]Bitboard = [64]Bitboard{} // for each piece, have it's pinray
	checkray        Bitboard     = max_bb
	checkers        int
	en_passant_file Bitboard
	turn            Color
	castling_rights u8 = all_castling_rights
	draw_counter    int
	move_counter    int
	history         []Move
	states          []StateHistory
	position_hash   Bitboard
	repetitions RepetitionTable
}

pub fn (mut b Board) recalc_pos_hash() {
	b.position_hash = empty_bb

	for sq, pc in b.pieces {
		b.position_hash ^= zobrist.read_piece(pc, sq)
	}
}

pub fn (mut b Board) add_piece(piece Piece, at int) {
	if b.pieces[at] == null_piece {
		b.pieces[at] = piece

		bit := square_bbs[at]

		b.bitboards[piece.type()] |= bit
		b.occupancies[piece.color()] |= bit
		b.occupancies[Occupancies.both] |= bit

		b.position_hash ^= zobrist.read_piece(piece, at)
	}
}

pub fn (mut b Board) remove_piece(at int) Piece {
	piece := b.pieces[at]

	b.pieces[at] = null_piece

	bit := square_bbs[at]

	b.bitboards[piece.type()] &= ~bit
	b.occupancies[piece.color()] &= ~bit
	b.occupancies[Occupancies.both] &= ~bit

	b.position_hash ^= zobrist.read_piece(piece, at)

	return piece
}

pub fn (mut b Board) move_piece(from int, to int) {
	piece := b.pieces[from]

	if piece != null_piece {
		b.pieces[from] = null_piece
		b.pieces[to] = piece

		f := square_bbs[from]
		t := square_bbs[to]
		// move := square_bbs[from] | square_bbs[to] 
		// ^^^ this broke for me for some reason, no quick XORing :(

		b.bitboards[piece.type()] &= ~f
		b.bitboards[piece.type()] |= t

		b.occupancies[piece.color()] &= ~f
		b.occupancies[piece.color()] |= t

		b.occupancies[Occupancies.both] &= ~f
		b.occupancies[Occupancies.both] |= t

		b.position_hash ^= zobrist.read_piece(piece, from)
		b.position_hash ^= zobrist.read_piece(piece, to)
	}
}

pub fn (mut b Board) load_fen(fen string) {
	properties := fen.split_by_space()

	for i, aspect in properties {
		match i {
			0 {
				mut file, mut rank := 0, 7
				for token in aspect.split('') {
					if token == '/' {
						file = 0
						rank--
					} else if token.is_int() {
						file += token.int()
					} else {
						index := rank * 8 + file
						if token.to_lower() in piecetype_symbols {
							type := symbol_to_piecetype[token.to_lower()]
							color := if token.str().is_upper() {
								Color.white
							} else {
								Color.black
							}

							b.add_piece(Piece.new(color, type), index)
							file++
						} else {
							eprintln("Invalid character token '${token}' found.\nFEN: ${fen}")
							exit(1)
						}
					}
				}
			}
			1 {
				if aspect in color_symbols {
					b.turn = symbol_to_color[aspect.to_lower()]
				}
			}
			2 {
				b.castling_rights = no_castling_rights
				for token in aspect.split('') {
					match token {
						'K' {
							b.castling_rights |= white_kingside_right
						}
						'k' {
							b.castling_rights |= black_kingside_right
						}
						'Q' {
							b.castling_rights |= white_queenside_right
						}
						'q' {
							b.castling_rights |= black_queenside_right
						}
						'-' {
							b.castling_rights = all_castling_rights
						}
						else {
							eprintln('Invalid token ${token} found in castling rights segment of the loading FEN. \nFEN: ${fen}')
							exit(1)
						}
					}
				}
			}
			3 {
				props := aspect.split('')
				file := props[0]

				if file in file_symbols {
					b.en_passant_file = symbol_to_file[file]
				}
			}
			4 {
				if aspect == '-' {
					b.draw_counter = 0
				} else if aspect.is_int() {
					b.draw_counter = aspect.int()
				}
			}
			5 {
				if aspect == '-' {
					b.draw_counter = 0
				} else if aspect.is_int() {
					b.move_counter = aspect.int()
				}
			}
			else {}
		}
	}

	b.update_attacks()
	b.recalc_pos_hash()
}

pub fn (b Board) get_fen() string {
	mut s := ''

	for rank := 7; rank >= 0; rank-- {
		mut empty_counter := 0
		for file := 0; file <= 7; file++ {
			index := rank * 8 + file

			piece := b.pieces[index]

			if piece == null_piece {
				empty_counter++
				continue
			} else {
				if empty_counter > 0 {
					s += empty_counter.str()
					empty_counter = 0
				}
			}

			s += piece.symbol()
		}

		if empty_counter > 0 {
			s += empty_counter.str()
			empty_counter = 0
		}

		if rank > 0 {
			s += '/'
		}
	}

	s += ' ${color_symbols[int(b.turn)]}'

	mut castling_rights := ''

	for i, flag in castling_flags {
		if (b.castling_rights & u8(flag)) > 0 {
			castling_rights += castling_symbols[i]
		}
	}

	s += ' ${castling_rights}'


	s += ' -'

	s += ' ${b.draw_counter} ${b.move_counter}'

	return s
}

pub fn (b Board) str() string {
	mut s := '\n'

	for rank := 7; rank >= 0; rank-- {
		for file := 0; file <= 7; file++ {
			piece := b.pieces[rank * 8 + file]
			if file == 0 {
				s += (rank + 1).str() + ' |'
			}
			if piece != null_piece {
				s += ' ${if piece.color() == .white {
					piece.symbol().to_upper()
				} else {
					piece.symbol()
				}} '
			} else {
				s += ' . '
			}
		}
		s += '\n'
	}

	s += '    a  b  c  d  e  f  g  h'
	return s
}

pub fn (b Board) print() {
	println(b.str())
}

pub fn (b Board) get_square_attackers(sq int, blockers Bitboard) Bitboard {
	us := b.turn
	enemy := us.opp()
	enemies := b.occupancies[enemy]
	orthogonal_sliders := (b.bitboards[Bitboards.queens] | b.bitboards[Bitboards.rooks]) & enemies
	diagonal_sliders := (b.bitboards[Bitboards.queens] | b.bitboards[Bitboards.bishops]) & enemies

	mut attackers := empty_bb

	attackers |= king_attacks[sq] & b.bitboards[Bitboards.kings] & enemies
	attackers |= pawn_attacks[us][sq] & b.bitboards[Bitboards.pawns] & enemies
	attackers |= knight_attacks[sq] & b.bitboards[Bitboards.knights] & enemies
	attackers |= bishop_attacks(sq, blockers) & diagonal_sliders
	attackers |= rook_attacks(sq, blockers) & orthogonal_sliders

	return attackers
}

pub fn (mut b Board) update_attacks() {
	us := b.turn
	opp := b.turn.opp()
	friendly := b.occupancies[us]
	enemy := b.occupancies[opp]
	king := b.bitboards[Bitboards.kings] & friendly
	k := king.lsb()

	b.pinned = [3]Bitboard{}
	b.pinray = [64]Bitboard{init: max_bb}
	b.checkers = 0
	b.checkray = empty_bb

	xray_attackers := b.get_square_attackers(k, enemy)

	mut scan := xray_attackers

	for scan > 0 {
		mut attacker := scan.pop_lsb()

		ray := ray_attacks[attacker][k] | square_bbs[attacker]

		in_between := ray & friendly

		if in_between.count() == 1 {
			b.pinned[us] |= in_between
			b.pinray[in_between.lsb()] = ray
		}

		if in_between == empty_bb {
			b.checkray |= ray
			b.checkers++
		}
	}
}

pub fn (mut b Board) make_move(move Move) {
	from := move.from_square()
	to := move.to_square()
	piece := move.piece()
	promotion := move.promotion()
	special := move.special()
	castle := move.castle()
	us := b.turn
	opp := us.opp()

	captured := b.pieces[to].type()

	b.states << StateHistory{captured, b.draw_counter, b.en_passant_file, b.castling_rights}

	b.move_counter++
	b.draw_counter++

	match special {
		.capture {
			target := b.pieces[to]

			assert target != null_piece && target == Piece.new(opp, captured)

			b.remove_piece(to)
		}
		.en_passant {
			target := square_bbs[to].forward(opp).lsb()
			targeted := b.pieces[target]

			if target == null_piece || targeted != Piece.new(opp, .pawn) {
				b.print()
				println(move.lan())
				panic('wtf')
			}

			b.remove_piece(target)
		}
		.pawn_double {
			assert to & 7 == from & 7

			b.en_passant_file = all_files[to & 7]
		}
		else {}
	}

	if special != .none || piece.type() == .pawn {
		b.draw_counter = 0
	}

	if special != .pawn_double {
		b.en_passant_file = empty_bb
	}

	if promotion != .none {
		assert piece == Piece.new(us, .pawn)

		b.remove_piece(from)

		b.add_piece(Piece.new(us, promotion), from)
	}

	match castle {
		.kingside {
			assert b.pieces[kingside_rook_from[us]] == Piece.new(us, .rook)

			b.move_piece(kingside_rook_from[us], kingside_rook_to[us])
		}
		.queenside {
			assert b.pieces[queenside_rook_from[us]] == Piece.new(us, .rook)

			b.move_piece(queenside_rook_from[us], queenside_rook_to[us])
		}
		else {
			match piece.type() {
				.king {
					b.castling_rights &= ~our_castling_rights[us]
				}
				.rook {
					kingside := our_kingside_right[us]
					queenside := our_queenside_right[us]
					match from {
						kingside_rook_from[us] {
							if (b.castling_rights & kingside) > 0 {
								b.castling_rights &= ~kingside
							}
						}
						queenside_rook_from[us] {
							if (b.castling_rights & queenside) > 0 {
								b.castling_rights &= ~queenside
							}
						}
						else {}
					}
				}
				else {}
			}
		}
	}

	b.move_piece(from, to)

	b.history << move
	b.repetitions.increment(b.position_hash)

	b.turn = b.turn.opp()
}

pub fn (mut b Board) undo_move() {
	b.repetitions.decrement(b.position_hash)
	
	move := b.history.pop()
	old_state := b.states.pop()

	from := move.from_square()
	to := move.to_square()
	captured := old_state.captured
	piece := move.piece()
	special := move.special()
	castle := move.castle()
	promotion := move.promotion()
	us := piece.color()
	opp := us.opp()

	assert b.turn == opp

	b.move_counter--
	b.draw_counter = old_state.halfmoves
	b.castling_rights = old_state.castling_rights
	b.en_passant_file = old_state.en_passant_file

	if b.pieces[to] == null_piece && special != .en_passant {
		// Mailbox Bitboard mismatch, always assert that the mailbox is wrong and correct it using the bitboards
		b.pieces[to] = piece
	}

	assert b.pieces[to] != null_piece

	b.move_piece(to, from)

	if captured != .none {
		b.add_piece(Piece.new(opp, captured), to)
	}

	if special == .en_passant {
		assert (square_bbs[to] & b.en_passant_file) > 0
		b.add_piece(Piece.new(opp, .pawn), if us == .white { to - 8 } else { to + 8 })
	}

	match castle {
		.kingside {
			assert b.pieces[kingside_rook_to[us]] == Piece.new(us, .rook)
			b.move_piece(kingside_rook_to[us], kingside_rook_from[us])
		}
		.queenside {
			assert b.pieces[queenside_rook_to[us]] == Piece.new(us, .rook)
			b.move_piece(queenside_rook_to[us], queenside_rook_from[us])
		}
		else {}
	}

	if promotion != .none {
		b.remove_piece(from)

		b.add_piece(Piece.new(us, .pawn), from)
	}

	b.turn = b.turn.opp()

	assert b.turn == us
}

pub fn (mut board Board) us_in_check() bool {
	board.update_attacks()

	return board.checkers > 1
}
