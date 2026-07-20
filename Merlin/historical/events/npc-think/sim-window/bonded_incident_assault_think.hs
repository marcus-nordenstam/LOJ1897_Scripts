; ----------------------------------------------------------------------------
; bonded_incident_assault (npc-think). An organic source of harm_act + wrong_act
; anchors: @self turns violent on a known acquaintance. The assault disposition is
; rolled ONCE per NPC (on the @self role) - the dark-tetrad product (volatility x
; psychopathy x sadism x low-politeness) with intoxication amplifying. The product
; is structurally tiny in a modal population (0.5^4 ~ 0.06), so the modal NPC
; almost never assaults; only the high-tetrad, intoxicated minority does.
;
; A mental change (the harm anchor + witness copies land), so npc-think. Fired by
; the per-NPC window-start pass. RELATIONAL: the victim is a personally-known
; acquaintance (a co-present "brawl at a venue" form awaits the venue lane - see
; public_incident_assault for the stranger case). The dark-tetrad chance on the
; @self role rolls ONCE per NPC (the old C++ dispatcher rolled it per-actor for
; exactly this reason: a per-victim re-roll inflated the rate by the pool size).
;
; NOTE: the exact base rate / intoxication-amplifier shape is RECONSTRUCTED from
; the design notes (the original gate lived in the retired run_social_incidents
; C++ dispatcher) - a tuning knob to validate against the crime/incident volume.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think bonded_incident_assault
  (schedule cooldown 1 m)
  (rng-stream incidents)

  ; @self is any human; the dark-tetrad assault disposition that rolls once
  ; per NPC now lives in the (when ...) gate below (a non-belief chance read
  ; cannot live on the role under the belief-purity invariant).
  (role @self )
  (role ?victim (any_human ?victim)
                (personally-knows @self ?victim))

  ; Dark-tetrad assault disposition, rolled once per NPC (moved off the @self
  ; role): volatility x psychopathy x sadism x (1 - politeness), amplified by
  ; intoxication (the 0.3 sober floor + 0.7*intox keeps the amplifier in
  ; [0.3, 1.0] so the whole product stays <= 1 - sober high-tetrad actors still
  ; occasionally fire, drunk ones much more).
  (when (chance (* (crime-scale)
                   (attr @self volatility)
                   (attr @self psychopathy)
                   (attr @self sadism)
                   (- 1.0 (attr @self politeness))
                   (+ 0.3 (* 0.7 (attr @self intoxication))))))

  (effects
    ; incident-anchor records the principals AND (engine-side auto-witness) the
    ; co-present bystanders, since assault is externally observable.
    (incident-anchor @self assault ?victim)
    ))
