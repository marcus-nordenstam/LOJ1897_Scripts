; ----------------------------------------------------------------------------
; public_incident_assault (PR-A-7 V2, 2026-05-28, multiplicative).
;
; First public_incident_* event. Same harm_act + wrong_act anchor as
; bonded_incident_assault, but with NO prior-bond requirement -
; binding via frequents-overlap captures the pub-brawl / public-
; square fight where actor and victim cross paths through shared
; haunts rather than personal acquaintance.
;
; The plan ("public_incident.hse - outcome table"):
;   Restricted to acts that don't require a prior bond: insult /
;   snub / threaten / appropriation (purse-snatch) / assault
;   (public brawl). Victim binding via frequents-overlap. Same
;   weight formula shape as bonded.
;
; Trait gates mirror bonded_incident_assault (volatility +
; psychopathy + sadism + low politeness + intoxication-amplifier)
; via multiplicative-chance. Structural difference is the binding
; predicate. Per-pair cooldown still applies.
;
; Public-context note (activity-lanes L6): binding is now real per-date
; co-presence, not the frequents-overlap proxy. (co-present ?actor ?victim)
; +(not (personally-knows ...)) captures STRANGERS who were at the same venue
; this date - the canonical pub-brawl / foyer-altercation. The bonded branch
; (bonded_incident_assault) takes the co-present pairs who already know each
; other, so the two never double-fire on one pair.
;
; categorize fires (identical to bonded_incident_assault):
;   victim (pov=patient):
;     - harm_act -> distress + fear + existential_threat pressure
;     - wrong_act -> anger + injustice pressure
;   actor (pov=actor):
;     - harm_act -> guilt + moral_violation pressure (sadism-gated)
;
; Schedule: (co-present) - activity-lanes L6. Day-close hook fires it per
; active date over the date's venue occupancy. Witnesses = the co-present set.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event public_incident_assault
  (nl       "?actor assaults ?victim in public")
  (kind     _public_incident_assault)
  ; EMERGENT (Section 4.11): no (schedule) - fired by the `brawl` affordance via
  ; resolve_affordances, suppressed from the DES. The (co-present ?a ?b) role
  ; filter binds the stranger victim from the venue's occupant set.
  (rng-stream incidents)

  (roles
    ; ?actor is PRE-BOUND by the day-close hook from the co-present set (never
    ; enumerated over the population); the actor trait gate lives once in C++
    ; (roll_incident_actor_gate) and is rolled by the hook before this fires.
    (role ?actor  (template any_human))
    (role ?victim (template any_human)
                  (not (= ?victim ?actor))
                  (co-present ?actor ?victim)
                  (not (personally-knows ?actor ?victim))
                  (not (has-recent-incident-marker ?actor ?victim))
                  ; 0.02 = 0.08 / k_default_dates_per_month (4): co-present
                  ; schedule fires this per active date, so spread the old
                  ; monthly 0.08 across the active days to hold monthly cadence.
                  (chance 0.02)))

  (effects
    (incident-anchor ?actor assault ?victim)
    (witness-copresence ?actor assault ?victim)
    (log _public_incident_assault ?actor)))
