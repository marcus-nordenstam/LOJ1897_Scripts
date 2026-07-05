; ----------------------------------------------------------------------------
; deliberate.hs - the ONE deliberation event, event-ized.
;
; The actor's standing pressure stack x the (pressure-kind, action) affinity table
; (deliberation_affinity.hs), reduced to ONE (pressure, action) pair by the joint
; kernel op (select-joint (over-pressures ...) (table ...) ...). The per-pair weight
; is (deliberation-score ...) - the term-free scorer over the loaded trait/mood/
; lethal/prize/crime-scale data - times disinhibition. The winner's score then
; competes ONCE against the inaction floor (forgive / do nothing); if the action
; wins, its goal {@self <action> <focus>} is minted with the driving pressure as
; /cause (the rap-sheet provenance).
;
; Replaces run_generative_deliberation (the C++ synthesizer). Deferred to the next
; increment (noted): the suicide + strive inline outlets, and the displacement /
; report-prop-fallback refinements.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event deliberate
  (sim-window-start)
  (rng-stream deliberation)

  ; Only pressured NPCs run the (expensive) joint reduction.
  (when (> (has-pressure @self) 0.0))

  ; Sample ONE (pressure, action) pair, weighted by the full deliberation score.
  ; ?pressure is the driving pressure belief (the goal's /cause); ?winscore is the
  ; chosen pair's score, for the act-vs-inaction pick below.
  (select-joint
    (over-pressures ?pk ?focus ?pressure)
    (table deliberation_affinity)
    (bind pressure_kind ?rpk)
    (bind action ?action)
    (bind weight ?weight)
    (bind-total ?total)
    (score (* (deliberation-score ?pressure ?rpk ?action ?focus ?weight)
              (disinhibition @self)))
    (policy weighted))

  ; The WHOLE candidate mass (?total) competes against the inaction floor - so the
  ; act-vs-abstain rate reflects all viable branches, not just the one sampled winner
  ; (?action). Acting mints the winner's goal; inaction does nothing.
  (branches
    (branch (weight ?total)
      (effects (resolve-deliberation ?action ?focus ?pressure)))
    (branch (weight (deliberation_inaction_floor))
      (effects))))
