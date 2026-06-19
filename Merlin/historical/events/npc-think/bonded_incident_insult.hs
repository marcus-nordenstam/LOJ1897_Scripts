; ----------------------------------------------------------------------------
; bonded_incident_insult (npc-think). The impulsive insult: @self lashes out at a
; known acquaintance. The actor's impulse is rolled ONCE per NPC (on the @self
; role): a dispositional base (low-politeness x narcissism) plus displaced anger
; (a high current ANGER load from ANY source raises the urge, discharged on
; whatever the victim pool offers). The victim is stance-weighted - the disliked
; and despised are preferentially hit, but a 0.10 floor lets displaced anger land
; on any acquaintance (the anger need not be AT the victim).
;
; A mental change (the insult anchor lands in both minds), so npc-think. Fired by
; the per-NPC window-start pass. RELATIONAL: the victim is a personally-known
; acquaintance (the social tie), not gated on physical co-presence - the retired
; place-lane provided the venue; the established reversion keys incidents on the
; tie, not co-presence (a co-present "insult at the venue" form awaits the venue
; lane). Putting the actor chance on the @self role rolls it ONCE per NPC, before
; the victim enumeration - the old (when ...)-on-a-preset-actor re-rolled per
; victim candidate and inflated the rate.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event bonded_incident_insult
  (sim-window-start)
  (nl       "@self insults ?victim")
  (rng-stream incidents)

  (roles
    ; The actor's impulse to lash out (rolled once per NPC): dispositional base
    ; (low-politeness x narcissism) + displaced anger (emotion-load).
    (role @self (template any_human)
                (chance (+ (* 0.06
                              (- 1.0 (attr @self politeness))
                              (attr @self narcissism))
                           (* 0.08 (emotion-load @self [k anger])))))
    (role ?victim (template any_human)
                  (not (= ?victim @self))
                  (personally-knows @self ?victim)
                  (not (has-recent-incident-marker @self ?victim))
                  ; Stance-weighted victim selection. Floor 0.10 is the
                  ; displaced-anger path (any acquaintance can be hit); negative
                  ; warmth (dislike/detest) and esteem (disdain/despise) add on top
                  ; - mild +0.15, strong +0.30 - so the despised are hit most.
                  ; believes folds to 0/1, so the sums are graded counts; static
                  ; max = 0.10 + 0.15*2 + 0.30*2 = 1.0.
                  (chance (+ 0.10
                             (* 0.15 (+ (believes @self {@self dislike ?victim})
                                        (believes @self {@self disdain ?victim})))
                             (* 0.30 (+ (believes @self {@self detest  ?victim})
                                        (believes @self {@self despise ?victim})))))))

  (effects
    (incident-anchor @self insult ?victim)
    (log _bonded_incident_insult @self)))
