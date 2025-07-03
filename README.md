# Visionary IX (V9)

A UCI compliant chess engine written in the V programming language.\
Current Version: 0.2.1\
Changelog: Removed quiesence search to avoid search explosions, pending the addition of transposition tables and move ordering.

Current Version: 0.2.2
Latest Feature: Move Ordering
>>>>>>> transposition-tables

## Features
- [x] Legal Move Generation
    - [x] Precalculated Leaper Attacks
    - [ ] Simple Magic Bitboard Slider Attacks
- [x] Negamax w/ Alpha-Beta Pruning
    - [x] Iterative Deepening
    - [ ] Move Ordering
<<<<<<< HEAD
      - [ ] MVV-LVA
      - [ ] Static Exchange Evaluation (SEE)
      - [ ] Killer Moves
      - [ ] History Heuristic
    - [ ] Quiesence Search (+150 elo)
=======
    - [ ] Transposition Tables
    - [ ] Quiesence Search (+150 before revert)
>>>>>>> transposition-tables
    - [ ] Aspiration Windows


## Notes
this takes so long to get right\
its basically torture for the first few steps (writing movegen)\
also features will have the elo gainer next to them when completed\
and more features will be added the more i learn about search selectivity\
uhhh what else goes here\
...\
lowkey this language kinda sucks for chess engine programming ngl\
how do i default dance using markdown
## Credits
- tabledotnet (me lmao)
- [chess programming discord](https://discord.com/invite/F6W6mMsTGN)
- [stockfish discord](https://discord.gg/GWDRS3kU6R)
- bbc chess engine series by [maksim korzh](https://github.com/maksimkorzh)
- chess coding adventure series by [sebastian lague](https://github.com/seblague)
