# events/classifiers

Derived-signal classifiers (the derived-signals program,
`Merlin/docs/derived_signals_program.md`). Each file here is an ordinary `.hs`
event (`npc-think`) that derives a per-mind category belief from what the mind
already holds.

Two shapes:

- **Band / toggle / argmax classifiers** -> `(sim-window-think)` (monthly) or
  `(year-think <month>)` (annual) events whose effect is `(mint-band ...)`
  (hysteresis + end-old/begin-new). Inputs are declared as `(role @self
  (believes {@self <input>}))` self-belief conjuncts, so the conjunction-driven
  intra-day agenda gates eligibility reactively - a classifier only runs for
  minds whose inputs are present, and re-bands on the event's cadence.

- **Value dims** (the magnitudes a fusion or utility reads, never minted as a
  belief) stay `(def ...)` expressions, inlined by consumers - not events.

Prompt state transitions (physical_mobility on death/injury, fallen_woman on
affair exposure) are minted by their triggering event, not a classifier here.
