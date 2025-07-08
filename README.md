# Visionary IX (V9)

A UCI compliant chess engine written in the V programming language.\
Current Version: 0.5 (+10 elo)\
Changelog: Incremented the depth when the side to move is in check in the search loop.

## Features
- [x] Legal Move Generation
    - [x] Precalculated Leaper Attacks
    - [ ] Simple Magic Bitboard Slider Attacks
- [x] Negamax w/ Alpha-Beta Pruning
    - [x] Iterative Deepening
    - [x] Transposition Tables (+150 elo)
    - [ ] Move Ordering
        - [x] PV Move
        - [x] TT Move
        - [x] Capture Moves (+85 elo)
        - [x] Killer Moves (+60 elo)
        - [ ] Simple History Bonus
    - [ ] Search Extensions
        - [x] Check Extensions (+10 elo)
    - [ ] Quiesence Search
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
- bbc chess engine series by [maksim korzh](https://github.com/maksimkorzh/bbc)
- chess coding adventure series by [sebastian lague](https://github.com/seblague/chess-coding-adventure)
