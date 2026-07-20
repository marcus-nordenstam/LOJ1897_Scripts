; ----------------------------------------------------------------------------
; economic_situation (classifier). Bands the wealth dimension into the
; {@self economic_situation <band>} belief.
;
; Per-NPC self-analysis. SCHEDULED on-commit (event-cadence Phase 2): the band is
; recomputed ONLY when @self's wealth belief is (re)committed - the input edge -
; not every sim-window. (if-blocked hold) so a wealth write that precedes the
; qualification (the (role @self (believes {@self wealth ?})) self-gate) still
; emits once the mind qualifies. A mind without a derived wealth is off-agenda and
; keeps its seeded band. (mint-band) carries the hysteresis dead-band + interval
; history: a value crossing ends the held band and begins the new one, a same-band
; value is a no-op.
;
; Band mins are the historical ascending upper bounds (15/30/45/60/75/90 on the
; 0..100 scale) read as descending entry thresholds on the 0..1 wealth dimension;
; the destitute floor (-1) always holds.
; ----------------------------------------------------------------------------

(npc-think classify_economic_situation
  (schedule on-commit)
  (if-blocked hold)
  (rng-stream behaviour)

  (role @self (believes {@self wealth ?}))

  (cont-fire-effects
    (mint-band {@self economic_situation} (target {@self wealth})
      [k economic_situation wealthy]     0.90
      [k economic_situation prosperous]  0.75
      [k economic_situation comfortable] 0.60
      [k economic_situation stable]      0.45
      [k economic_situation struggling]  0.30
      [k economic_situation poor]        0.15
      [k economic_situation destitute]  -1)))
