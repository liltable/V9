module chess

pub struct ScorePair {
	middlegame i16
	endgame i16
}

pub const null_score_pair = ScorePair { 0, 0 }

pub const pawn_scores = [
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 180, 272 }
        ScorePair { 216, 267 }
        ScorePair { 143, 252 }
        ScorePair { 177, 228 }
        ScorePair { 150, 241 }
        ScorePair { 208, 226 }
        ScorePair { 116, 259 }
        ScorePair { 71, 281 }
        ScorePair { 76, 188 }
        ScorePair { 89, 194 }
        ScorePair { 108, 179 }
        ScorePair { 113, 161 }
        ScorePair { 147, 150 }
        ScorePair { 138, 147 }
        ScorePair { 107, 176 }
        ScorePair { 62, 178 }
        ScorePair { 68, 126 }
        ScorePair { 95, 118 }
        ScorePair { 88, 107 }
        ScorePair { 103, 99 }
        ScorePair { 105, 92 }
        ScorePair { 94, 98 }
        ScorePair { 99, 111 }
        ScorePair { 59, 111 }
        ScorePair { 55, 107 }
        ScorePair { 80, 103 }
        ScorePair { 77, 91 }
        ScorePair { 94, 87 }
        ScorePair { 99, 87 }
        ScorePair { 88, 86 }
        ScorePair { 92, 97 }
        ScorePair { 57, 93 }
        ScorePair { 56, 98 }
        ScorePair { 78, 101 }
        ScorePair { 78, 88 }
        ScorePair { 72, 95 }
        ScorePair { 85, 94 }
        ScorePair { 85, 89 }
        ScorePair { 115, 93 }
        ScorePair { 70, 86 }
        ScorePair { 47, 107 }
        ScorePair { 81, 102 }
        ScorePair { 62, 102 }
        ScorePair { 59, 104 }
        ScorePair { 67, 107 }
        ScorePair { 106, 94 }
        ScorePair { 120, 96 }
        ScorePair { 60, 87 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
        ScorePair { 82, 94 }
]

pub const knight_scores = [
        ScorePair { 170, 223 }
        ScorePair { 248, 243 }
        ScorePair { 303, 268 }
        ScorePair { 288, 253 }
        ScorePair { 398, 250 }
        ScorePair { 240, 254 }
        ScorePair { 322, 218 }
        ScorePair { 230, 182 }
        ScorePair { 264, 256 }
        ScorePair { 296, 273 }
        ScorePair { 409, 256 }
        ScorePair { 373, 279 }
        ScorePair { 360, 272 }
        ScorePair { 399, 256 }
        ScorePair { 344, 257 }
        ScorePair { 320, 229 }
        ScorePair { 290, 257 }
        ScorePair { 397, 261 }
        ScorePair { 374, 291 }
        ScorePair { 402, 290 }
        ScorePair { 421, 280 }
        ScorePair { 466, 272 }
        ScorePair { 410, 262 }
        ScorePair { 381, 240 }
        ScorePair { 328, 264 }
        ScorePair { 354, 284 }
        ScorePair { 356, 303 }
        ScorePair { 390, 303 }
        ScorePair { 374, 303 }
        ScorePair { 406, 292 }
        ScorePair { 355, 289 }
        ScorePair { 359, 263 }
        ScorePair { 324, 263 }
        ScorePair { 341, 275 }
        ScorePair { 353, 297 }
        ScorePair { 350, 306 }
        ScorePair { 365, 297 }
        ScorePair { 356, 298 }
        ScorePair { 358, 285 }
        ScorePair { 329, 263 }
        ScorePair { 314, 258 }
        ScorePair { 328, 278 }
        ScorePair { 349, 280 }
        ScorePair { 347, 296 }
        ScorePair { 356, 291 }
        ScorePair { 354, 278 }
        ScorePair { 362, 261 }
        ScorePair { 321, 259 }
        ScorePair { 308, 239 }
        ScorePair { 284, 261 }
        ScorePair { 325, 271 }
        ScorePair { 334, 276 }
        ScorePair { 336, 279 }
        ScorePair { 355, 261 }
        ScorePair { 323, 258 }
        ScorePair { 318, 237 }
        ScorePair { 232, 252 }
        ScorePair { 316, 230 }
        ScorePair { 279, 258 }
        ScorePair { 304, 266 }
        ScorePair { 320, 259 }
        ScorePair { 309, 263 }
        ScorePair { 318, 231 }
        ScorePair { 314, 217 }
]

pub const bishop_scores = [
        ScorePair { 336, 283 }
        ScorePair { 369, 276 }
        ScorePair { 283, 286 }
        ScorePair { 328, 289 }
        ScorePair { 340, 290 }
        ScorePair { 323, 288 }
        ScorePair { 372, 280 }
        ScorePair { 357, 273 }
        ScorePair { 339, 289 }
        ScorePair { 381, 293 }
        ScorePair { 347, 304 }
        ScorePair { 352, 285 }
        ScorePair { 395, 294 }
        ScorePair { 424, 284 }
        ScorePair { 383, 293 }
        ScorePair { 318, 283 }
        ScorePair { 349, 299 }
        ScorePair { 402, 289 }
        ScorePair { 408, 297 }
        ScorePair { 405, 296 }
        ScorePair { 400, 295 }
        ScorePair { 415, 303 }
        ScorePair { 402, 297 }
        ScorePair { 363, 301 }
        ScorePair { 361, 294 }
        ScorePair { 370, 306 }
        ScorePair { 384, 309 }
        ScorePair { 415, 306 }
        ScorePair { 402, 311 }
        ScorePair { 402, 307 }
        ScorePair { 372, 300 }
        ScorePair { 363, 299 }
        ScorePair { 359, 291 }
        ScorePair { 378, 300 }
        ScorePair { 378, 310 }
        ScorePair { 391, 316 }
        ScorePair { 399, 304 }
        ScorePair { 377, 307 }
        ScorePair { 375, 294 }
        ScorePair { 369, 288 }
        ScorePair { 365, 285 }
        ScorePair { 380, 294 }
        ScorePair { 380, 305 }
        ScorePair { 380, 307 }
        ScorePair { 379, 310 }
        ScorePair { 392, 300 }
        ScorePair { 383, 290 }
        ScorePair { 375, 282 }
        ScorePair { 369, 283 }
        ScorePair { 380, 279 }
        ScorePair { 381, 290 }
        ScorePair { 365, 296 }
        ScorePair { 372, 301 }
        ScorePair { 386, 288 }
        ScorePair { 398, 282 }
        ScorePair { 366, 270 }
        ScorePair { 332, 274 }
        ScorePair { 362, 288 }
        ScorePair { 351, 274 }
        ScorePair { 344, 292 }
        ScorePair { 352, 288 }
        ScorePair { 353, 281 }
        ScorePair { 326, 292 }
        ScorePair { 344, 280 }
]

pub const rook_scores = [
        ScorePair { 509, 525 }
        ScorePair { 519, 522 }
        ScorePair { 509, 530 }
        ScorePair { 528, 527 }
        ScorePair { 540, 524 }
        ScorePair { 486, 524 }
        ScorePair { 508, 520 }
        ScorePair { 520, 517 }
        ScorePair { 504, 523 }
        ScorePair { 509, 525 }
        ScorePair { 535, 525 }
        ScorePair { 539, 523 }
        ScorePair { 557, 509 }
        ScorePair { 544, 515 }
        ScorePair { 503, 520 }
        ScorePair { 521, 515 }
        ScorePair { 472, 519 }
        ScorePair { 496, 519 }
        ScorePair { 503, 519 }
        ScorePair { 513, 517 }
        ScorePair { 494, 516 }
        ScorePair { 522, 509 }
        ScorePair { 538, 507 }
        ScorePair { 493, 509 }
        ScorePair { 453, 516 }
        ScorePair { 466, 515 }
        ScorePair { 484, 525 }
        ScorePair { 503, 513 }
        ScorePair { 501, 514 }
        ScorePair { 512, 513 }
        ScorePair { 469, 511 }
        ScorePair { 457, 514 }
        ScorePair { 441, 515 }
        ScorePair { 451, 517 }
        ScorePair { 465, 520 }
        ScorePair { 476, 516 }
        ScorePair { 486, 507 }
        ScorePair { 470, 506 }
        ScorePair { 483, 504 }
        ScorePair { 454, 501 }
        ScorePair { 432, 508 }
        ScorePair { 452, 512 }
        ScorePair { 461, 507 }
        ScorePair { 460, 511 }
        ScorePair { 480, 505 }
        ScorePair { 477, 500 }
        ScorePair { 472, 504 }
        ScorePair { 444, 496 }
        ScorePair { 433, 506 }
        ScorePair { 461, 506 }
        ScorePair { 457, 512 }
        ScorePair { 468, 514 }
        ScorePair { 476, 503 }
        ScorePair { 488, 503 }
        ScorePair { 471, 501 }
        ScorePair { 406, 509 }
        ScorePair { 458, 503 }
        ScorePair { 464, 514 }
        ScorePair { 478, 515 }
        ScorePair { 494, 511 }
        ScorePair { 493, 507 }
        ScorePair { 484, 499 }
        ScorePair { 440, 516 }
        ScorePair { 451, 492 }
]

pub const queen_scores = [
        ScorePair { 997, 927 }
        ScorePair { 1025, 958 }
        ScorePair { 1054, 958 }
        ScorePair { 1037, 963 }
        ScorePair { 1084, 963 }
        ScorePair { 1069, 955 }
        ScorePair { 1068, 946 }
        ScorePair { 1070, 956 }
        ScorePair { 1001, 919 }
        ScorePair { 986, 956 }
        ScorePair { 1020, 968 }
        ScorePair { 1026, 977 }
        ScorePair { 1009, 994 }
        ScorePair { 1082, 961 }
        ScorePair { 1053, 966 }
        ScorePair { 1079, 936 }
        ScorePair { 1012, 916 }
        ScorePair { 1008, 942 }
        ScorePair { 1032, 945 }
        ScorePair { 1033, 985 }
        ScorePair { 1054, 983 }
        ScorePair { 1081, 971 }
        ScorePair { 1072, 955 }
        ScorePair { 1082, 945 }
        ScorePair { 998, 939 }
        ScorePair { 998, 958 }
        ScorePair { 1009, 960 }
        ScorePair { 1009, 981 }
        ScorePair { 1024, 993 }
        ScorePair { 1042, 976 }
        ScorePair { 1023, 993 }
        ScorePair { 1026, 972 }
        ScorePair { 1016, 918 }
        ScorePair { 999, 964 }
        ScorePair { 1016, 955 }
        ScorePair { 1015, 983 }
        ScorePair { 1023, 967 }
        ScorePair { 1021, 970 }
        ScorePair { 1028, 975 }
        ScorePair { 1022, 959 }
        ScorePair { 1011, 920 }
        ScorePair { 1027, 909 }
        ScorePair { 1014, 951 }
        ScorePair { 1023, 942 }
        ScorePair { 1020, 945 }
        ScorePair { 1027, 953 }
        ScorePair { 1039, 946 }
        ScorePair { 1030, 941 }
        ScorePair { 990, 914 }
        ScorePair { 1017, 913 }
        ScorePair { 1036, 906 }
        ScorePair { 1027, 920 }
        ScorePair { 1033, 920 }
        ScorePair { 1040, 913 }
        ScorePair { 1022, 900 }
        ScorePair { 1026, 904 }
        ScorePair { 1024, 903 }
        ScorePair { 1007, 908 }
        ScorePair { 1016, 914 }
        ScorePair { 1035, 893 }
        ScorePair { 1010, 931 }
        ScorePair { 1000, 904 }
        ScorePair { 994, 916 }
        ScorePair { 975, 895 }
]

pub const king_scores = [
        ScorePair { -65, -74 }
        ScorePair { 23, -35 }
        ScorePair { 16, -18 }
        ScorePair { -15, -18 }
        ScorePair { -56, -11 }
        ScorePair { -34, 15 }
        ScorePair { 2, 4 }
        ScorePair { 13, -17 }
        ScorePair { 29, -12 }
        ScorePair { -1, 17 }
        ScorePair { -20, 14 }
        ScorePair { -7, 17 }
        ScorePair { -8, 17 }
        ScorePair { -4, 38 }
        ScorePair { -38, 23 }
        ScorePair { -29, 11 }
        ScorePair { -9, 10 }
        ScorePair { 24, 17 }
        ScorePair { 2, 23 }
        ScorePair { -16, 15 }
        ScorePair { -20, 20 }
        ScorePair { 6, 45 }
        ScorePair { 22, 44 }
        ScorePair { -22, 13 }
        ScorePair { -17, -8 }
        ScorePair { -20, 22 }
        ScorePair { -12, 24 }
        ScorePair { -27, 27 }
        ScorePair { -30, 26 }
        ScorePair { -25, 33 }
        ScorePair { -14, 26 }
        ScorePair { -36, 3 }
        ScorePair { -49, -18 }
        ScorePair { -1, -4 }
        ScorePair { -27, 21 }
        ScorePair { -39, 24 }
        ScorePair { -46, 27 }
        ScorePair { -44, 23 }
        ScorePair { -33, 9 }
        ScorePair { -51, -11 }
        ScorePair { -14, -19 }
        ScorePair { -14, -3 }
        ScorePair { -22, 11 }
        ScorePair { -46, 21 }
        ScorePair { -44, 23 }
        ScorePair { -30, 16 }
        ScorePair { -15, 7 }
        ScorePair { -27, -9 }
        ScorePair { 1, -27 }
        ScorePair { 7, -11 }
        ScorePair { -8, 4 }
        ScorePair { -64, 13 }
        ScorePair { -43, 14 }
        ScorePair { -16, 4 }
        ScorePair { 9, -5 }
        ScorePair { 8, -17 }
        ScorePair { -15, -53 }
        ScorePair { 36, -34 }
        ScorePair { 12, -21 }
        ScorePair { -54, -11 }
        ScorePair { 8, -28 }
        ScorePair { -28, -14 }
        ScorePair { 24, -24 }
        ScorePair { 14, -43 }
]
//                             none, p, n, b, r, q, k
pub const gamephase_inc = [0, 0, 1, 1, 2, 4, 0]

pub fn (piece Piece) get_score_pair(sq int) ScorePair {
	match piece.type() {
		.pawn {
			return pawn_scores[sq]
		}
		.knight {
			return knight_scores[sq]
		}
		.bishop {
			return bishop_scores[sq]
		}
		.rook {
			return rook_scores[sq]
		}
		.queen {
			return queen_scores[sq]
		}
		.king {
			return king_scores[sq]
		}
		else {
			return null_score_pair
		}
	}
}