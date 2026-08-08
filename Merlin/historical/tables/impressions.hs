; ----------------------------------------------------------------------------
; impressions.hs - the abduction v2 impression map: which perceived-character
; kind a witnessed act's trait-gated (chance (attr @self <trait>) ...) term
; evidences, and at what authored strength. Read by build_abduction_index (C++)
; via hse_table_lookup: witnessing an episode whose gate reads (attr @self <trait>)
; makes the bystander abduce {actor seem <kind>} at <weight>. The gate's own
; numeric constants are RATE constants, so the evidence strength is authored here.
;
;   trait   - the personality attr the act's (chance ...) gate reads (the KEY).
;   kind    - the [k impression <leaf>] the witness abduces about the actor.
;   weight  - the authored evidence strength (0..1).
; ----------------------------------------------------------------------------

(define-table impressions
  (fields trait         kind                          weight)
  (record volatility    [k impression hot_tempered]   0.6)
  (record psychopathy   [k impression callous]        0.5)
  (record sadism        [k impression cruel]          0.5)
  (record narcissism    [k impression selfish]        0.4))
