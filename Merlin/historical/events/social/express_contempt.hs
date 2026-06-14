; ----------------------------------------------------------------------------
; express_contempt.
;
; The DELIBERATE, attitude-driven insult - the considered counterpart to the
; impulsive bonded_incident_insult. Where that event is a trait roll
; (low politeness x narcissism) that merely BIASES its victim toward the
; disliked, this one is GATED on the attitude itself: the actor holds the
; target in deep contempt (the esteem stance has reached the `despise` band,
; -2) and occasionally lets it show as a cutting remark.
;
; This fills a real gap the impulsive path leaves open: a NON-narcissist who
; despises someone never insults them under bonded_incident_insult's
; narcissism gate. Contempt finds expression regardless of impulsiveness -
; here the driver is the contempt, modulated only by callousness (low
; compassion expresses it readily; the compassionate restrain it even toward
; the despised).
;
; Delivered as an event, NOT a perpetration method: the perpetration pipeline
; selects methods from pressure-derived goals (deliberation.hs affinity rows),
; with no stance input, so it cannot host an attitude-driven act. The reliable
; stance gate (stance-at-least despise, the cross-pair BITSET
; predicate) carries the intent directly, and the non-root
; (chance ...) gates correctly.
;
; Re-uses the `insult` incident anchor (so the victim's existing contempt /
; anger reaction fires) + the per-pair 90-day cooldown (no carpet-bombing).
;
; EMERGENT (Section 4.11): no (schedule) - fired by the `insult` affordance via
; resolve_affordances (place-lane); the despised victim binds from co-presence.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event express_contempt
  (nl       "?actor treats ?victim with open contempt")
  (kind     _express_contempt)
  (band      evening)
  (rng-stream incidents)

  (roles
    (role ?actor  (template any_human)
                  (>= (years-old ?actor) 18))
    (role ?victim (template any_human)
                  (not (= ?victim ?actor))
                  ; Place model (b1-1 fix): contempt is shown to someone's face -
                  ; only to a target you are co-present with this date.
                  (co-present ?actor ?victim)
                  ; the actor holds ?victim in deep contempt (esteem `despise`,
                  ; the strong negative band) - the reliable cross-pair bitset.
                  (stance-at-least ?actor ?victim despise)
                  (not (has-recent-incident-marker ?actor ?victim))
                  ; how readily the contempt surfaces: the callous (low
                  ; compassion) cut openly; the compassionate hold it in even
                  ; toward those they despise. Driver is the attitude, not the
                  ; narcissism/politeness traits the impulsive path keys on.
                  ; Low base: open contempt is a pointed, deliberate act, so it
                  ; stays rarer than the impulsive bonded_incident_insult even
                  ; though despise is common in a conflict-heavy population.
                  (chance (* 0.04 (- 1.0 (attr ?actor compassion))))))

  (effects
    (incident-anchor ?actor insult ?victim :context cold_contempt)
    (log _express_contempt ?actor)))
