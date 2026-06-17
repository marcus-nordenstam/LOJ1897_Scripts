; ----------------------------------------------------------------------------
; bonded_incident_assault (PR-A-7 V2, 2026-05-28, multiplicative).
;
; Organic source of harm_act + wrong_act anchors. Replaces
; test_seed_assault's chance-primary scaffold; the latter retires
; under PR-A-10 once substrate-rooted coverage is broad enough.
;
; The plan's outcome row:
;   assault | volatility x psychopathy x sadism x low politeness
;           | intoxication x stress x aggression-situation
;           | LIFE_AIM_ALIGN -respectability, -piety
;
; V2 gating: multiplicative-chance over four traits + an intoxication
; AMPLIFIER. The four-way trait product is structurally tiny in a
; modal population (0.5^4 = 0.0625); a high base rate (1.0) +
; intoxication as an additive bonus (0.3 floor + intox so sober
; actors still occasionally fire, drunk actors fire much more)
; produces a smooth gradient across the population.
;
;   At modal (vol 0.5, psy 0.5, sad 0.5, pol 0.5, intox 0.1):
;     1.0 x 0.5 x 0.5 x 0.5 x 0.5 x 0.4 = 0.0125 per actor-month
;   At extreme (vol 0.8, psy 0.7, sad 0.7, pol 0.2, intox 0.6):
;     1.0 x 0.8 x 0.7 x 0.7 x 0.8 x 0.9 = 0.282 per actor-month
;
; So a true dark-tetrad villain fires ~22x more often than a modal
; NPC. The V1 boolean gates produced 0 fires in 97 years; the
; multiplicative form yields a continuous spectrum.
;
; categorize fires:
;   victim (pov=patient):
;     - harm_act -> distress + fear + existential_threat pressure
;     - wrong_act -> anger + injustice pressure
;   actor (pov=actor):
;     - harm_act -> guilt + moral_violation pressure (sadism-gated)
;
; Schedule: (co-present) - activity-lanes L6. NOT on the DES; the day-close
; co-presence hook fires it once per active date after that date's activity
; events have built the venue occupancy, so (co-present ?actor ?victim) binds a
; victim from the actor's actual venue-mates this date (a known one - the
; bonded branch). A domestic assault is just this event resolving at a HOME
; venue (household co-presence now exists). Per-pair 90-day cooldown via
; recent_incident. Witnesses = the rest of that venue's co-present set.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event bonded_incident_assault
  (nl       "?actor assaults ?victim")
  (kind     _bonded_incident_assault)
  ; EMERGENT (Section 4.11): no (schedule) - fired by the `brawl` affordance via
  ; resolve_affordances (the venue offers it to its co-present occupants),
  ; suppressed from the DES. The (co-present ?a ?b) role filter binds the victim.
  (rng-stream incidents)

  (roles
    ; ?actor is PRE-BOUND by run_social_incidents AFTER it has rolled the actor's
    ; dark-tetrad assault disposition ONCE per actor (vol x psy x sad x (1-pol) x
    ; intox-amplifier). That decision lives in the dispatcher (not a (when ...) gate
    ; here): a per-actor gate must roll once, but a (when ...) on a preset-actor
    ; event re-rolls per victim candidate, which inflates with the victim pool size
    ; (the stranger pool made public_incident_assault fire ~40x the bonded one). So
    ; the dispatcher decides WHO turns violent; this event only binds the victim.
    (role ?actor  (template any_human))
    (role ?victim (template any_human)
                  (not (= ?victim ?actor))
                  (co-present ?actor ?victim)
                  (personally-knows ?actor ?victim)
                  (not (has-recent-incident-marker ?actor ?victim))))

  (effects
    (incident-anchor ?actor assault ?victim)
    (witness-copresence ?actor assault ?victim)
    (log _bonded_incident_assault ?actor)))
