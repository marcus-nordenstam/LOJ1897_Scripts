# rules/classifiers

Derived-signal classifiers (the derived-signals program,
`Merlin/docs/derived_signals_program.md`). Each file here is an ordinary `.hs`
rule (`npc-think`) that derives a per-mind category belief from what the mind
already holds.

Two shapes:

- **Band / toggle / argmax classifiers** -> `(npc-think)` rules whose effect is
  `(mint-band ...)` (hysteresis + end-old/begin-new). Inputs are declared as
  `(role @self (believes {@self <input>}))` self-belief conjuncts, so a
  classifier is gated reactively - it only runs for minds whose inputs are
  present, and re-bands when they change. A `(cooldown 1 m)` paces the re-band
  where the inputs drift continuously (respectability, devoutness, conduct,
  contentment, life-aim); the rest re-band whenever an input belief changes.

- **Value dims** (the magnitudes a fusion or utility reads, never minted as a
  belief) stay `(def ...)` expressions, inlined by consumers - not rules.

Prompt state transitions (physical_mobility on death/injury, fallen_woman on
affair exposure) are minted by their triggering rule, not a classifier here.
