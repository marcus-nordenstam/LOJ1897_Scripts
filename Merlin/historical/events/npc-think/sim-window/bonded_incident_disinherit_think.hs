; ----------------------------------------------------------------------------
; bonded_incident_disinherit (PR-A-7 V2, 2026-05-28, multiplicative).
;
; Organic source of abandonment_act + wrong_act anchors. Replaces
; test_seed_disinheritance's chance-primary scaffold; the latter
; retires under PR-A-10 once substrate-rooted coverage is broad enough.
;
; The plan's outcome row:
;   disinherit / desert / fire
;       | low compassion x narcissism
;       | requires authority-over x value-rift
;       | LIFE_AIM_ALIGN +legacy, +respectability
;
; V2 gating: multiplicative-chance over (1 - compassion) x narcissism
; on the actor side; the family-disinheritance variant gates on
; actor-is-parent-of-victim (the authority-over predicate for the
; family case).
;
; V3: disinheritance needs GROUNDS. The victim side is stance-gated
; with NO floor: the father must already hold the child in standing
; disregard (dislike/detest warmth or disdain/despise esteem - the
; bands the child's own conduct eroded), else the event cannot fire.
; A callous patriarch no longer cuts off a beloved child on a trait
; roll - the Louis Green pathology (he avenged his daughter against
; his own brother, then disinherited her unprompted). The old
; value-rift amplifier was a dead placeholder (no event mints value
; beliefs; modal rift = 0 behind a 0.2 floor) and is dropped; real
; value-rift grounds (a child's scandalous marriage / disgrace) can
; re-enter as amplifiers when value beliefs exist.
;
; categorize fires:
;   victim (pov=patient):
;     - abandonment_act -> grief + distress + attachment_loss
;                          pressure + status_loss pressure +
;                          end-bonds (love / friend)
;     - wrong_act -> anger + injustice pressure + humiliation
;   actor (pov=actor):
;     - abandonment_act -> guilt + moral_violation pressure
;     - wrong_act -> guilt + fear + moral_violation +
;                    exposure_risk pressure
;
; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (relational: parent-of-victim + standing disregard, no co-presence). MONTHLY
; now, so the actor (chance) base is /12 (0.30 -> 0.025) to hold annual volume.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think bonded_incident_disinherit
  (sim-window-think)
  (rng-stream incidents)

  (role @self  (any_human @self))
  (role ?victim (any_human ?victim)
                (not (= ?victim @self))
                (believes {@self child ?victim}))

  ; Grounds, not a floor: mild standing disregard (dislike / disdain) admits the cut
  ; at 0.2 each, deep disregard (detest / despise) at 0.3 each; a child the father
  ; holds no grudge against CANNOT be disinherited. believes folds to 0/1; static max
  ; 1.0. A non-belief (chance) gate reading per-victim stance, rolled per victim at
  ; firing, so it lives in (when), not as a role criterion (would not be cacheable).
  ; The actor trait (chance) gate ((1 - compassion) x narcissism) moved here off the
  ; @self role for the same reason (attr reads are non-belief, not role-cacheable).
  (when (and (chance (* (crime-scale) 0.025
                        (- 1.0 (attr @self compassion))
                        (attr @self narcissism)))
             (chance (+ (* 0.2 (+ (believes {@self dislike ?victim})
                                  (believes {@self disdain ?victim})))
                        (* 0.3 (+ (believes {@self detest  ?victim})
                                  (believes {@self despise ?victim})))))))

  (effects
    (incident-anchor @self disinherit ?victim)
    ))
