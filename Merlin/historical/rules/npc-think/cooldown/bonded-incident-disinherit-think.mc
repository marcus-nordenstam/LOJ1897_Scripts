; ----------------------------------------------------------------------------
; bonded_incident_disinherit (PR-A-7 V2, 2026-05-28, multiplicative).
;
; Organic source of abandonment-act + wrong-act anchors. Replaces
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
; bands the child's own conduct eroded), else the rule cannot fire.
; A callous patriarch no longer cuts off a beloved child on a trait
; roll - the Louis Green pathology (he avenged his daughter against
; his own brother, then disinherited her unprompted). The old
; value-rift amplifier was a dead placeholder (no rule mints value
; beliefs; modal rift = 0 behind a 0.2 floor) and is dropped; real
; value-rift grounds (a child's scandalous marriage / disgrace) can
; re-enter as amplifiers when value beliefs exist.
;
; categorize fires:
;   victim (pov=patient):
;     - abandonment-act -> grief + distress + attachment-loss
;                          pressure + status-loss pressure +
;                          end-bonds (love / friend)
;     - wrong-act -> anger + injustice pressure + humiliation
;   actor (pov=actor):
;     - abandonment-act -> guilt + moral-violation pressure
;     - wrong-act -> guilt + fear + moral-violation +
;                    exposure-risk pressure
;
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think bonded_incident_disinherit
  (cooldown 1 m)
  (rng-stream incidents)

  (role @self  {@self isa [k human], condition [k alive]})
  (role ?victim {?victim isa [k human], condition [k alive]}
                {@self child ?victim})

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
             (chance (+ (* 0.2 (+ (prob {@self dislike ?victim})
                                  (prob {@self disdain ?victim})))
                        (* 0.3 (+ (prob {@self detest  ?victim})
                                  (prob {@self despise ?victim})))))))

  (utility want)

  ; Propose the disinherit TASK (disinherit-task.hs): the benefactor performs the
  ; disinheritance - not a fabricated omniscient record. (Interim: the task SAYs it to
  ; the victim, planting the knowledge; the proper will-writing + heir-realization lands
  ; when will-documents do.)
  (effects
    (begin-proposal {@self disinherit ?victim})))
