; ----------------------------------------------------------------------------
; economic-situation (classifier). Bands the wealth dimension into the
; {@self economic-situation <band>} belief.
;
; Per-NPC self-analysis. The (role @self {@self wealth ?}) self-gate
; qualifies a mind for banding; a mind without a derived wealth keeps its seeded
; band until it qualifies. (mint-band) carries the hysteresis dead-band + interval
; history: a value crossing ends the held band and begins the new one, a same-band
; value is a no-op.
;
; Band mins are the historical ascending upper bounds (15/30/45/60/75/90 on the
; 0..100 scale) read as descending entry thresholds on the 0..1 wealth dimension;
; the destitute floor (-1) always holds.
; ----------------------------------------------------------------------------

(npc-think classify_economic_situation
  (rng-stream behaviour)

  (role @self {@self wealth ?wealth})

  (effects
    (mint-band {@self economic-situation} ?wealth
      [k economic-situation wealthy]     0.90
      [k economic-situation prosperous]  0.75
      [k economic-situation comfortable] 0.60
      [k economic-situation stable]      0.45
      [k economic-situation struggling]  0.30
      [k economic-situation poor]        0.15
      [k economic-situation destitute]  -1)))
