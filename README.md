## EECE320: Digital Systems Design

## Tarneeb Referee: A Combinational Trick Evaluation Circuit

Tarneeb is a four-player card game popular in Lebanon and the wider Middle East. In
this project, we designed a "Tarneeb Referee", a digital circuit that, given a designated tarneeb suit, identifies the winner of a set of four played cards and detects invalid card combinations.

The design is purely combinational, written in hierarchical behavioral Verilog-2001, and verified with a self-checking testbench on Icarus Verilog.

---

## Specification

### Rules of a trick

Four players (0–3) each play one card. One suit is designated the **tarneeb** (trump) suit.

1. **Player 0 always leads.** The suit of `card0` is the **lead suit**.
2. If any tarneeb card is played, the **highest-ranked tarneeb card** wins.
3. Otherwise, the **highest-ranked lead-suit card** wins.
4. A card that is neither tarneeb nor the lead suit can never win, whatever its rank.

Ranks go 2 < 3 < … < 10 < J (11) < Q (12) < K (13) < A (14). Any tarneeb card beats any non-tarneeb card.

Examples (cards listed for players 0–3):

| Cards | Tarneeb | Winner | Why |
|---|---|---|---|
| 10♥ K♥ 3♣ 7♥ | ♠ | Player 1 | No spade played; K♥ is the highest heart |
| A♥ 2♠ K♥ 10♥ | ♠ | Player 1 | 2♠ is the only tarneeb card, so it beats A♥ |
| 9♦ J♦ A♣ 4♠ | ♥ | Player 1 | No heart played; J♦ is the highest diamond; A♣ is off-suit |

### Card encoding

Each card is 8 bits: `{rank[5:0], suit[1:0]}`.

| Suit | Code | Suit | Code |
|---|---|---|---|
| ♣ Clubs | `00` | ♦ Diamonds | `01` |
| ♥ Hearts | `10` | ♠ Spades | `11` |

| Card | Encoding | Hex |
|---|---|---|
| 10♥ | `{6'd10, 2'b10}` | `8'h2A` |
| A♠ | `{6'd14, 2'b11}` | `8'h3B` |
| 2♣ | `{6'd2, 2'b00}` | `8'h08` |

To decode a hex value, divide by 4: the quotient is the rank and the remainder is the suit. For example, `8'h36` = 54 = 13 × 4 + 2, which is K♥.

### Interface

```verilog
module tarneeb_referee (
    input  [7:0] card0, card1, card2, card3,
    input  [1:0] tarneeb,
    output [1:0] winner,
    output       valid
);
```

| Signal | Width | Meaning |
|---|---|---|
| `card0`–`card3` | 8 | Cards played by players 0–3 |
| `tarneeb` | 2 | Trump suit |
| `winner` | 2 | Index (0–3) of the winning player |
| `valid` | 1 | 1 if the input is four legal, distinct cards |

### Invalid inputs

`valid = 0` and `winner = 00` when:

- any card has a rank below 2 or above 14 (e.g. `8'h00` is rank 0, `8'h3E` is rank 15), or
- any two cards are identical in both rank and suit (e.g. `8'h32` appearing twice).

Cards with the same rank in different suits are distinct: `8'h36` (K♥) and `8'h37` (K♠) together are valid. Every 2-bit suit and tarneeb value is legal.

When `valid = 0`, `winner = 00` has no meaning. It is the same code as "player 0 wins", so always check `valid` before reading `winner`.

---

## Architecture

```
tarneeb_referee
├── input_validator
│   └── rank_checker ×4     2 ≤ rank ≤ 14 for each card
└── trick_evaluator
    └── card_beats ×3       does the challenger beat the current best?
```

- **`input_validator`** combines the four rank checks with six pairwise comparisons of the full 8-bit cards (0–1, 0–2, 0–3, 1–2, 1–3, 2–3).
- **`trick_evaluator`** keeps a running "best so far". `card0` starts as the best card; `card1`, `card2` and `card3` each challenge it in turn, and multiplexers carry the best card and its player index forward.
- **`card_beats`** decides one comparison:

  ```
  beats = (challenger is tarneeb AND best is not tarneeb)
       OR (same suit AND challenger rank > best rank)
  ```

  This short rule is correct because the current best is always a lead-suit or tarneeb card, since the chain starts from `card0`.
- **Top level** forces `winner` to `00` whenever `valid = 0`.

---

## Running the simulation

**Locally (Icarus Verilog):**

```sh
iverilog -g2001 -o sim design.sv testbench.sv
vvp sim
gtkwave dump.vcd    # optional: view the timing diagram
```

**EDA Playground:** select Icarus Verilog, paste `design.sv` and `testbench.sv`, and tick *Open EPWave after run* to see the waveform.

Expected output:

```
Test 1:  PASS (No tarneeb played, highest lead-suit card wins)
...
Test 21: PASS (Invalid rank 18 for card 3)
--------------------------------
Passed: 21  Failed: 0
--------------------------------
```

---

## Verification

The testbench instantiates only `tarneeb_referee`, so it can be run against any implementation with the same interface. Each test sets the inputs, waits 10 time units, and compares `valid` and `winner` with `===` against expected values worked out by hand from the rules. On failure it prints the expected and actual outputs and the inputs:

```
Test 1: FAIL expected (valid=1, winner=1), got (valid=1, winner=0)
  inputs: card0=2a card1=36 card2=0c card3=1e tarneeb=11
```

The testbench also writes `dump.vcd` for waveform viewing.

### Test vectors

Cards and tarneeb are in hex. `(v,w)` is the expected `(valid, winner)`.

| # | card0 | card1 | card2 | card3 | T | Decoded | (v,w) | Scenario |
|---|---|---|---|---|---|---|---|---|
| 1 | 2A | 36 | 0C | 1E | 3 | 10♥ K♥ 3♣ 7♥ / ♠ | (1,1) | No tarneeb; highest lead-suit card wins |
| 2 | 3A | 0B | 36 | 2A | 3 | A♥ 2♠ K♥ 10♥ / ♠ | (1,1) | Low tarneeb beats lead-suit Ace |
| 3 | 25 | 2D | 38 | 13 | 2 | 9♦ J♦ A♣ 4♠ / ♥ | (1,1) | No tarneeb; off-suit Ace loses |
| 4 | 14 | 38 | 37 | 0B | 3 | 5♣ A♣ K♠ 2♠ / ♠ | (1,2) | Multiple tarneeb; highest wins |
| 5 | 32 | 32 | 0C | 11 | 3 | Q♥ Q♥ 3♣ 4♦ / ♠ | (0,0) | Duplicate pair 0–1 |
| 6 | 00 | 12 | 15 | 1B | 3 | rank 0 in card 0 | (0,0) | Invalid rank 0 |
| 7 | 2D | 25 | 30 | 2A | 1 | J♦ 9♦ Q♣ 10♥ / ♦ | (1,0) | Lead suit is the tarneeb suit |
| 8 | 3A | 2B | 2A | 14 | 0 | A♥ 10♠ 10♥ 5♣ / ♣ | (1,3) | Low tarneeb wins for player 3 |
| 9 | 34 | 1D | 32 | 26 | 2 | K♣ 7♦ Q♥ 9♥ / ♥ | (1,2) | Multiple tarneeb; highest wins |
| 10 | 16 | 1B | 25 | 16 | 3 | 5♥ 6♠ 9♦ 5♥ / ♠ | (0,0) | Duplicate pair 0–3 |
| 11 | 3E | 0E | 20 | 13 | 1 | rank 15 in card 0 | (0,0) | Invalid rank 15 |
| 12 | 04 | 2A | 2D | 0F | 0 | rank 1 in card 0 | (0,0) | Invalid rank 1 |
| 13 | 1A | 38 | 0E | 35 | 3 | 6♥ A♣ 3♥ K♦ / ♠ | (1,0) | Higher off-suit card loses to lower lead-suit card |
| 14 | 2A | 36 | 0C | 3C | 3 | rank 15 in card 3 | (0,0) | Invalid rank outside card 0 |
| 15 | 14 | 1E | 1E | 37 | 3 | 5♣ 7♥ 7♥ K♠ / ♠ | (0,0) | Duplicate pair 1–2 |
| 16 | 2A | 36 | 2A | 0C | 3 | 10♥ K♥ 10♥ 3♣ / ♠ | (0,0) | Duplicate pair 0–2 |
| 17 | 14 | 1E | 37 | 1E | 3 | 5♣ 7♥ K♠ 7♥ / ♠ | (0,0) | Duplicate pair 1–3 |
| 18 | 3A | 0B | 26 | 26 | 3 | A♥ 2♠ 9♥ 9♥ / ♠ | (0,0) | Duplicate pair 2–3 |
| 19 | 2A | 04 | 36 | 1E | 3 | rank 1 in card 1 | (0,0) | Invalid rank 1 in card 1 |
| 20 | 2A | 36 | 02 | 1E | 3 | rank 0 in card 2 | (0,0) | Invalid rank 0 in card 2 |
| 21 | 2A | 36 | 0C | 4A | 3 | rank 18 in card 3 | (0,0) | Invalid rank 18 (low 4 bits look like 2) |

### Coverage

| Scenario | Tests |
|---|---|
| No tarneeb played; highest lead-suit card wins | 1, 3 |
| Tarneeb beats a higher-ranked lead-suit card | 2, 8 |
| Multiple tarneeb cards; highest wins | 4, 9 |
| Lead suit is the tarneeb suit | 7 |
| Higher off-suit card loses to lower lead-suit card | 13 |
| Duplicate cards (all six pairs) | 5, 10, 15, 16, 17, 18 |
| Invalid ranks 0, 1, 15 and 18 (in every card position) | 6, 11, 12, 14, 19, 20, 21 |

Across the valid vectors, every player wins at least once (player 0: 7, 13; player 1: 1–3; player 2: 4, 9; player 3: 8), and both rank 2 and the Ace appear.

Some tests also check secondary behavior:

- Test 8 has 10♠ and 10♥ in one valid trick, which checks that the same rank in different suits is not a duplicate.
- Tests 10 and 15 would produce a nonzero winner if the input were valid, which checks that `winner` is forced to `00` on invalid input.
- The duplicate tests cover all six card pairs and the invalid-rank tests place a bad rank in every card position, so a design that skips one comparison or one card is detected.
- Test 21 uses rank 18 (`6'b010010`), whose low four bits look like a legal rank 2, to catch a rank check that ignores the upper bits.

---

## Discussion

### Assumptions

- **Player 0 always leads.** The lead suit is taken directly from `card0[1:0]`. In the full game the winner of a trick leads the next one; the referee does not model this rotation.
- **One completed trick, no state.** The circuit sees all four cards at once and holds no memory. Bidding, scoring and earlier tricks are outside its scope.
- **Stable inputs.** We know that outputs are only really meaningful once the inputs have settled to their values. The testbench waits 10 time units after each change; no additional timing analysis was done beyond that.
- **A card is identified by all eight bits.** Two cards are duplicates only if both rank and suit match. Equal ranks in different suits are distinct cards (Test 8 contains both the 10 of Spades and the 10 of Hearts).
- **All suit and tarneeb codes are legal.** Both fields are two bits wide and every value maps to a suit, so they need no validation.
- **`winner` is only meaningful when `valid = 1`.** For invalid inputs, `winner` is forced to `00`, the same code as "player 0 wins". ANY circuit that uses the referee must check `valid` before reading `winner`.

### Limitations

- **No follow-suit check.** The players' hands are not inputs, so the referee cannot detect a player who discards off-suit while still holding a lead-suit card. Though, admittedly, we are not really good at card games, and Tarneeb especially, we believe this is the most common rule violation in the real game, and it happens to pass as a valid trick in our implementation.
- **Single-bit validity.** When `valid = 0`, the output does not say whether a rank was out of range or a card was repeated, nor which card caused it. Finding the cause requires inspecting the inputs or internal signals.
- **Serial comparison chain.** The three `card_beats` stages and their multiplexers form a chain, so the evaluator's delay grows linearly with the number of cards. For four cards the cost is small, but the structure does not scale well.
- **`card_beats` depends on an invariant.** The simplified rule is only correct because the current best card is always of the lead or tarneeb suit, which holds because the chain starts from `card0`. The module cannot be reused to compare two arbitrary cards, e.g. in a tree of comparisons.
- **Finite, hand-derived tests.** The 21 vectors cover every required scenario, but the input space has 2³⁴ combinations. The expected outputs were derived by hand from the same reading of the rules used to write the design, so a misunderstanding of a rule would appear in both and go undetected.
- **Repetitive testbench.** Each test is a copy of the same block with different values. This makes the file long, and errors in copied lines are easy to miss: one failure message contained a stray typo that was only found on review.

### Possible improvements

- **Priority key instead of pairwise rules.** Each card can be mapped to a key `{is_tarneeb, is_lead, rank}`. Off-suit cards then have a smaller key than any lead-suit card, and tarneeb cards a larger key than both, so the winner is simply the card with the largest key. Because each key is computed independently, the four keys can be compared in a two-level tree (cards 0 and 1, and cards 2 and 3, in parallel, then the two winners). This shortens this critical path from three stages to only two, while also removing the invariant that `card_beats` relies on.
- **Error code output.** `valid` could be extended with a small code giving the type of error (e.g. bad rank or duplicate) and the index of the offending card.
- **"Follow-suit" checking.** If each player's hand were provided, e.g. as a 52-bit mask, the referee could flag a player who did not follow the lead suit while holding a card of that suit.
- **Full-game controller.** Sequential logic could track the leading player from trick to trick, count tricks per team, and keep the score.
- **Stronger correctness guarantees.** A behavioral reference model in the testbench, written separately from the design, could be compared against it on a large set of random vectors, or exhaustively over a reduced space (all suit and tarneeb combinations with a few chosen ranks). Alternatively, storing the directed vectors in an array (or similar) and then checking them in a loop would also remove the repetitive code.

---

## Authors

Daniel Dia and Hiba Salman, EECE 320 (Digital Systems Design), American University of Beirut.