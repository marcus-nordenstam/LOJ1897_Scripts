; ----------------------------------------------------------------------------
; public_incident_assault (npc-think). The stranger-victim assault - a public
; brawl / square fight where @self turns violent on someone NOT personally known,
; bound from the live co-presence (you can only brawl with whoever is actually
; THERE). Same dark-tetrad actor disposition as bonded_incident_assault, rolled
; ONCE per NPC on the @self role; the structural difference is the victim is a
; co-present STRANGER, not a known acquaintance.
;
; A mental change (the harm anchor + witness copies; the stranger-anonymity
; machinery gives the unknown perp/victim an unnamed object), so npc-think. Fired
; by the per-NPC window-start pass. CO-PRESENT is KEPT here (unlike the bonded
; incidents): the victim MUST be co-located - witness-copresence registers the
; scene at @self's location, so a non-present victim would be incoherent. It
; therefore fires only when @self happens to share a location with a stranger
; (rare and realistic for public brawls); the full place-lane form - @self out
; among strangers at a venue - awaits the venue/leisure routing lane.
;
; NOTE: the dark-tetrad base rate / intoxication amplifier is RECONSTRUCTED from
; the design notes (the original gate lived in the retired run_social_incidents
; C++ dispatcher) - a tuning knob.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event public_incident_assault
  (sim-window-start)
  (nl       "@self assaults ?victim in public")
  (rng-stream incidents)

  (roles
    ; Dark-tetrad assault disposition, rolled once per NPC (see
    ; bonded_incident_assault for the formula rationale).
    (role @self (template any_human)
                (chance (* (attr @self volatility)
                           (attr @self psychopathy)
                           (attr @self sadism)
                           (- 1.0 (attr @self politeness))
                           (+ 0.3 (* 0.7 (attr @self intoxication))))))
    (role ?victim (template any_human)
                  (not (= ?victim @self))
                  ; the victim is co-present (physically THERE) and a STRANGER.
                  (co-present @self ?victim)
                  (not (personally-knows @self ?victim))
                  (not (has-recent-incident-marker @self ?victim))))

  (effects
    (incident-anchor @self assault ?victim)
    (witness-copresence @self assault ?victim)
    (log _public_incident_assault @self)))
