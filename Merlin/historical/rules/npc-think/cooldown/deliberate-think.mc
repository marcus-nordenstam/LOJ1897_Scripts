; ----------------------------------------------------------------------------
; deliberate.hs - the ONE deliberation rule, rule-ized.
;
; The actor's standing pressure stack x the (pressure-kind, action) affinity table
; (deliberation_affinity.hs), reduced to ONE (pressure, action) pair by the joint
; kernel op (select-joint (over-pressures ...) (table ...) ...). The per-pair weight
; is (deliberation-score ...) - the .hs scorer (deliberation_macros.hs) composing
; intensity x affinity x trait/mood/justify/lethal/prize/crime-scale - times
; disinhibition, over the (= ?pk ?rpk) kind-matched pairs. The winner's score then
; competes ONCE against the inaction floor (forgive / do nothing); if the action
; wins, its goal {@self <action> <focus>} is minted with the driving pressure as
; /caused_by (the rap-sheet provenance).
;
; Replaces run_generative_deliberation (the C++ synthesizer). Deferred to the next
; increment (noted): the suicide + strive inline outlets, and the displacement /
; report-prop-fallback refinements.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think deliberate
  (cooldown 1 m)
  (rng-stream deliberation)

  ; Only pressured NPCs run the (expensive) joint reduction, and only while crime runs:
  ; (> (crime-scale) 0) shuts the whole deliberation outlet - proposed crimes AND the kill
  ; campaign - off cleanly when crime is switched off.
  (when (and (> (has-pressure @self) 0.0)
             (> (crime-scale) 0)))

  ; Deliberated responses ride the want tier. The value is @self's disinhibition (0..1 ->
  ; the want axis): a disinhibited actor's response competes high in the tier, an inhibited
  ; one's rides low and loses to ordinary wants. (select-joint binds - ?action / ?winscore /
  ; ?pressure - are NOT in scope for the utility clause, so the value is an actor-global
  ; read, and the migrated-crime split lives in resolve-deliberation.)
  (utility want (* (disinhibition) 1000))

  ; Sample ONE (pressure, action) pair, weighted by the full deliberation score.
  ; ?pressure is the driving pressure belief (the goal's /caused_by); ?winscore is the
  ; chosen pair's score, for the act-vs-inaction pick below.
  (select-joint
    (over-pressures ?pk ?focus ?pressure)
    (table deliberation_affinity)
    (bind pressure-kind ?rpk)
    (bind action ?action)
    (bind weight ?weight)
    (bind-total ?total)
    (when (= ?pk ?rpk))
    (score (* (disinhibition)
              (deliberation-score ?pressure ?action ?focus ?weight)))
    (policy roulette))

  ; The WHOLE candidate mass (?total) competes against the inaction floor - so the
  ; act-vs-abstain rate reflects all viable branches, not just the one sampled winner
  ; (?action). Acting mints the winner's goal; inaction does nothing.
  (branches
    (branch (weight ?total)
      (effects (resolve-deliberation ?action ?focus ?pressure)))
    (branch (weight (deliberation_inaction_floor))
      (effects))))
