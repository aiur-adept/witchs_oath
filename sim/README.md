# Arcana Monte Carlo Simulator

A Python multiprocess Monte Carlo simulator that mirrors the GDScript match engine
(`arcana_match_state.gd`) and plays two greedy AI pilots against each other.

## Usage

```powershell
python -m sim.run --deck noble_test --runs 100000 [--seed 0] [--workers N]
```

- `--deck`: P0 deck slug. Must be listed in `included_decks/index.json`.
- `--runs`: total simulated games (default 100k).
- `--seed`: master RNG seed for reproducibility. Each worker seeds from this.
- `--workers`: override worker count; defaults to `os.cpu_count()`.

## What it does

1. Loads all decks from `included_decks/*.json` listed in `index.json`.
2. Spawns one worker process per CPU core and gives each worker `runs / workers`
   games to play.
3. Each game: shuffle, London-mulligan heuristic, random first player, then
   greedy AI pilots both sides until somebody hits 20 match power, decks out, or
   a 400-turn safety cap fires.
4. Each shard folds its games into a per-opponent bucket keyed by the P1 deck
   slug; the parent merges shards with elementwise sums.
5. Accounting invariants are asserted on the merged aggregate before reporting.
6. Reports per-opponent win/loss/draw table, match-power progression, and
   final-power histograms for P0 and P1.

## Modeled mechanics

All of Set 1 per `design_document.md` is implemented:

- Rituals 1–4 with the standard active-lane chain (value N active iff all k<N have
  an active ritual or lane-granting noble).
- Incantations: `seek`, `insight`, `burn`, `woe`, `wrath 4`, `revive 1`, `deluge
  2–4`, `tears 3`.
- `dethrone 4`.
- All 15 nobles (Krss/Trss/Yrss/Xytzr/Yytzr/Zytzr/Aeoiu + 5 Incantation nobles +
  3 Scions).
- All 5 temples, including Eyrie ETB bird search, Gotha draw-skip static,
  Delpha sac → burn → replay ritual, Ytria hand-cycle.
- Birds with cost/power catalog, bird-lane activation from wild-bird power sum,
  simple bird combat, and nesting into temples.
- All 5 rings (Sybiline/Cymbil/Celadon/Serraf/Sinofia): lane-2 cost, attach to a
  noble or un-nested bird, additive cost reductions (floor 0) on spells/units
  matching each ring's reductions, shed to crypt when the host is destroyed,
  and block nesting for any bird carrying a ring.
- Pending-response FIFO for Woe (opponent target), Eyrie (bird pick), and the
  three Scion triggers (Rmrsk/Smrsk/Tmrsk).
- Win at ≥20 match power or on empty-deck draw attempt; draw on ties and on the
  turn cap.

## Known simplifications

- Bird combat uses single-attacker / single-defender pairings rather than the
  general "pick two sets" ruling — the greedy AI never benefits from complex
  multi-target combats.
- Revive chain is single-cast (no Yytzr extra-sac step).
- Insight reordering picks "send N to bottom" only; it does not attempt to
  permute the top stack. The AI uses this to bottom known-useless cards from
  the opponent.
- Mulligan is a simple heuristic: mulligan if 0 rituals, all rituals, or
  ritual-heavy with no lane-1.
- The 400-turn cap is not in the rules; it guards against pathological stalls.

## Per-slug accounting

Each worker returns a dict keyed by `p1_slug`, with an identical schema produced
by `_empty_bucket()`. Fields are integers or lists of integers; merging shards
is an elementwise `+=`. After merging, the runner asserts:

- `p0_wins + p1_wins + draws == games` per bucket.
- `sum(end_reason_counts.values()) == games` per bucket.
- `sum(final_power_hist_p0) == games` per bucket (same for P1).
- `Σ games == total_runs` globally.

If any invariant is violated the runner fails loudly before printing.
