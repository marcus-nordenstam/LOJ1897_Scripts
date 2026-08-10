; ----------------------------------------------------------------------------
; bonded_incident_insult (npc-think). The impulsive insult: @self lashes out at a
; known acquaintance. The actor's impulse is gated in (when): a dispositional
; base (low-politeness x narcissism) plus displaced anger
; (a high current ANGER load from ANY source raises the urge, discharged on
; whatever the victim pool offers). The victim is stance-weighted - the disliked
; and despised are preferentially hit, but a 0.10 floor lets displaced anger land
; on any acquaintance (the anger need not be AT the victim).
;
; A mental change (the insult anchor lands in both minds), so npc-think, per
; NPC. RELATIONAL: the victim is a personally-known
; acquaintance (the social tie), not gated on physical co-presence - the retired
; place-lane provided the venue; the established reversion keys incidents on the
; tie, not co-presence (a co-present "insult at the venue" form awaits the venue
; lane). The actor impulse and the victim-stance gate are both non-belief (chance)
; tests, so they live in (when); the @self role carries only its template.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think bonded_incident_insult
  (cooldown 1 m)
  (rng-stream incidents)

  ; The actor's impulse to lash out: dispositional base (low-politeness x
  ; narcissism) + displaced anger (emotion-load). The (chance) gate is non-belief
  ; (not role-cacheable), so it lives in (when) below, not on this role.
  (role @self )
  (role ?victim (any_human ?victim)
                (personally-knows @self ?victim))

  ; Stance-weighted victim selection. Floor 0.10 is the displaced-anger path (any
  ; acquaintance can be hit); negative warmth (dislike/detest) and esteem (disdain/
  ; despise) add on top - mild +0.15, strong +0.30 - so the despised are hit most.
  ; believes folds to 0/1, so the sums are graded counts; static max = 1.0. A non-
  ; belief (chance) gate reading per-victim stance, rolled per victim at firing, so
  ; it lives in (when), not as a role criterion (would not be cacheable).
  ; MOVED from the @self role (non-belief, not role-cacheable): the actor's impulse
  ; chance (dispositional base + displaced anger). Both gates are (chance), kept first.
  (when (and (chance (+ (* (crime-scale) 0.06
                           (- 1.0 (attr @self politeness))
                           (attr @self narcissism))
                        (* (crime-scale) 0.08 (emotion-load @self [k anger]))))
             (chance (+ 0.10
                        (* 0.15 (+ (any {@self dislike ?victim} (out int))
                                   (any {@self disdain ?victim} (out int))))
                        (* 0.30 (+ (any {@self detest  ?victim} (out int))
                                   (any {@self despise ?victim} (out int))))))))

  (effects
    ; Context picks the barb ladder: a high standing anger load marks the
    ; displaced-anger lash-out (perceptual barbs, what's at hand); otherwise
    ; the dispositional put-down (status barbs) - mirroring the two additive
    ; impulse sources in (when).
    (insult-anchor ?victim
      (if (> (emotion-load @self [k anger]) 0.5) (then displaced_anger) (else dispositional)))
    ))
