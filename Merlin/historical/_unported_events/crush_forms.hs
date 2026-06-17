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
; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (relational, gated on personally-knows; no physical co-presence needed), once
; a month, same rate as the old monthly cadence. The infatuation belief, once
; minted, persists
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
  (band      afternoon)
  (rng-stream incidents)

  ; PLACE-EMERGENT (Section 4.11): the crush sparks on someone the actor is
  ; CO-PRESENT with this band (a venue spark, incl. the workplace), via the
  ; `crush_forms` affordance. ?actor is PRESET from the venue's occupants, so its
  ; eligibility (single, romantically-open) moves to the (when) gate below - preset
  ; role-0 skips its own role filters (the lovers/love_match pattern).
  (roles
    (role ?actor (template any_human))
    (role ?victim (template any_human)
                  (not (= ?victim ?actor))
                  (>= (years-old ?victim) 14)
                  (<= (years-old ?victim) 60)
                  ; the crush ignites on whoever the actor SHARES THE VENUE with.
                  (co-present ?actor ?victim)
                  ; No incestuous crush (reliable kin cross-pair BITSET).
                  (not (kin ?actor ?victim))
                  ; Opposite-sex (period-default hetero majority; attr read).
                  (not (= (attr ?victim gender) (attr ?actor gender)))
                  (<= (- (years-old ?actor) (years-old ?victim))  10)
                  (>= (- (years-old ?actor) (years-old ?victim)) -10)))

  ;; Actor eligibility (preset role-0 skips role filters, so it lives here): a
  ;; romantically-open single, not already deep in a crush. The trait chance
  ;; (openness x enthusiasm x compassion) makes the receptive crush more readily.
  (when (and (>= (years-old ?actor) 14)
             (<= (years-old ?actor) 50)
             (not (believes ?actor {@self desire ?}))
             (not (believes ?actor {@self lover ?}))
             (not (believes ?actor {@self spouse ?}))
             (chance (* 0.30
                        (attr ?actor openness)
                        (attr ?actor enthusiasm)
                        (attr ?actor compassion)))))

  (effects
    ; Feed the one-sided attraction scalar:
    ; a crush is a strong directed pull. 0.5 crosses the `fancy` band (0.20) in
    ; one fire and sustains ~a year against the sleep decay (0.938); repeated
    ; fires deepen toward `desire` (0.60). The `fancy` verb-state belief is what
    ; courtship (betrothal / advantageous_match) now reads.
    (nudge-stance ?actor ?victim attraction 0.5)
    (log _crush_forms ?actor)))
