# Visionary IX (V9)

A UCI compliant chess engine written in the V programming language.\
Current Version: 0.1\

## Features
This list is modeled after the [pinned message](https://discord.com/channels/435943710472011776/882956631514689597/1256706716515565638) in the Stockfish Discord channel. More features will be added as progression continues.
- [x] Legal Move Generation
    - [x] Precalculated Leaper Attacks
    - [x] Simple Magic Bitboard Slider Attacks
    - [x] Staged Move Generation
- [x] Negamax w/ Alpha-Beta Pruning
    - [x] Iterative Deepening
    - [x] Transposition Tables (+200 elo)
    - [x] Move Ordering
        - [x] Captures First
        - [ ] MVV-LVA (+20 elo)
        - [ ] TT Entry Move First
        - [ ] Killer Moves
    - [ ] Quiesence Search (+200 elo)
    - [ ] Butterfly History Tables
    - [ ] Principal Variation Search
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
- tabledotnet (me lol)
- [chess programming discord](https://discord.com/invite/F6W6mMsTGN)
- [stockfish discord](https://discord.gg/GWDRS3kU6R)
- bbc chess engine series by [maksim korzh](https://github.com/maksimkorzh/bbc)
- chess coding adventure series by [sebastian lague](https://github.com/seblague/chess-coding-adventure)
