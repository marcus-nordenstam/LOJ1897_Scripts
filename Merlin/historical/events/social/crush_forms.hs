; ----------------------------------------------------------------------------
; crush_forms (PR-A-9, 2026-05-28).
;
; A romantic-openness NPC develops a directed infatuation toward someone
; they encounter through shared haunts. Mints {actor infatuation victim}
; in the actor's mind - read downstream by appraise_obsession (the
; emotion-driven deliberation branch) and by opportunity events that
; gate on standing infatuation. The attachment_pursuit pressure family
; (planned) will eventually consume the infatuation belief to amplify
; specific deliberation branches.
;
; Substrate-rooted: no chance-primary pick. Actor gates on (openness x
; enthusiasm x compassion) trait product (people open to new feeling,
; outgoing, and warm) AND no current infatuation / lover / spouse
; (single people develop crushes; the already-attached don't refresh).
; Victim binds via personally-knows (you develop a crush on someone you
; have actually met) plus an age-band check. The activity-lanes co-presence
; sweep seeds the acquaintance ties this reads - strangers who keep crossing
; paths at a venue become acquaintances first, then crush material (a one-
; cycle lag). This replaced the old frequents-overlap haunt proxy when the
; static frequents seed was retired (activity-lanes L8).
;
; Schedule: monthly. The infatuation belief, once minted, persists
; through normal belief decay until a romantic event (betrothal /
; advantageous_match / crush_lapses-PLANNED) supersedes it. No
; transient_marker cooldown - a person can carry only one infatuation
; per @excl on the verb-state, so re-mint just refreshes the same
; belief (mx_begin_belief's @excl handling).
;
; Wait - infatuation in States.mon (line 94) is NOT declared @excl.
; That's intentional: an NPC may carry interest in multiple targets
; over time. The cooldown is implicit in the not-already-infatuated
; gate - a person with a held infatuation skips the event.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event crush_forms
  (nl       "?actor forms a crush on ?victim")
  (kind     _crush_forms)
  (schedule (monthly))
  (rng-stream incidents)

  (roles
    ; NB: inline role filters use the EXPLICIT role var (?actor / ?victim), not
    ; ?self. A `?self` in an inline filter that also references the OTHER role
    ; (the age-gap below) mis-compiles and silently drops the trailing chance
    ; residue (hse engine quirk found 2026-06-06) - so the gate would never fire.
    (role ?actor  (template any_human)
                  (>= (years-old ?actor) 14)
                  (<= (years-old ?actor) 50)
                  ; infatuation retired (relational_stance_plan.md Phase 4):
                  ; directed attraction is now the attraction stance SCALAR
                  ; (fancy/desire/crave verb-states), driven by mate-value in the
                  ; standing pass. This event is a dispositional narrative beat for
                  ; a romantically-open single not already deep in a crush. It does
                  ; NOT target-gate on the fancied person: a TARGET-SPECIFIC
                  ; `(believes ?actor {@self fancy ?victim})` does NOT gate (hse
                  ; two-bound-var believes limitation, 2026-06-06); and the
                  ; attraction scalar is gender-gated so it is sparse in hsim (a
                  ; target's gender is known only for believe_about'd contacts).
                  (not (believes ?actor {@self desire ?}))
                  (not (believes ?actor {@self lover ?}))
                  (not (believes ?actor {@self spouse ?}))
                  (chance (* 0.30
                             (attr ?actor openness)
                             (attr ?actor enthusiasm)
                             (attr ?actor compassion))))
    (role ?victim (template any_human)
                  (not (= ?victim ?actor))
                  (>= (years-old ?victim) 14)
                  (<= (years-old ?victim) 60)
                  (personally-knows ?actor ?victim)
                  (<= (- (years-old ?actor) (years-old ?victim))  10)
                  (>= (- (years-old ?actor) (years-old ?victim)) -10)
                  (chance 0.20)))

  (effects
    ; No belief mint - the `fancy` verb-state IS the durable crush. This event
    ; surfaces it as a narrative beat.
    (log _crush_forms ?actor)))
