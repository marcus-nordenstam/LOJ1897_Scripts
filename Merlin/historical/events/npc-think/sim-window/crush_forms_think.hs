; ----------------------------------------------------------------------------
; crush_forms (npc-think). A romantic-openness NPC develops a directed
; infatuation toward someone they have met. Feeds the one-sided attraction scalar
; (the `fancy` verb-state belief) - read downstream by appraise_obsession (the
; emotion-driven deliberation branch), by the courtship machinery (love_match /
; court read `fancy`), and by opportunity events that gate on standing
; infatuation.
;
; A mental change (a new attraction), so npc-think. Fired by the per-NPC emergent
; pass MONTHLY. RELATIONAL, gated on personally-knows: a crush forms on someone
; the actor has actually met (the acquaintance ties the conversation / friendship
; lanes seed), NOT on whoever shares a room - a SPECIFIC attracted pair rarely
; coincides physically by chance, so courtship FORMATION is keyed on the social
; tie, not co-presence (the settled reversion; a place-lane "spark at a venue"
; form is a future refinement).
;
; Actor gates on the (openness x enthusiasm x compassion) trait product (people
; open to new feeling, outgoing, and warm) AND no current desire / lover / spouse
; (single people develop crushes; the already-attached don't refresh). The
; not-already-infatuated gate is implicit in the not-desire filter - a person
; deep in a crush (at the `desire` band) skips. Victim binds via personally-knows
; plus opposite-sex, non-kin and an age-band check.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think crush_forms
  (schedule cooldown 1 m)
  (rng-stream incidents)

  ;; @self - a romantically-open single, not already deep in a crush. The trait
  ;; chance (openness x enthusiasm x compassion) gates the receptive crush; it now
  ;; lives in (when ...) below (non-belief filters do not belong in a role).
  (role @self 
              (working-age @self)
              (not (believes {@self desire ?}))
              (not (believes {@self lover ?}))
              (not (believes {@self spouse ?})))
  (role ?victim (any_human ?victim)
                (marriageable-age ?victim)
                ; the crush forms on someone @self has actually met.
                (personally-knows @self ?victim)
                ; No incestuous crush (kin cross-pair believes-macro).
                (not (blood-kin @self ?victim))
                ; Opposite-sex: @self's belief that ?victim's PERCEIVED gender
                ; differs from his own (visible-on-sight -> cacheable).
                (not (believes {?victim gender (target {@self gender})}))
                ; Similar age: same or adjacent perceived age-band (the belief-pure
                ; replacement for the old +/-10 year window).
                (age-peers @self ?victim))

  ; Moved from the @self role: the trait chance (openness x enthusiasm x
  ; compassion) is a non-belief filter, so it is rolled once per NPC per window
  ; here rather than inside the role.
  (when (chance (* 0.30
                   (attr @self openness)
                   (attr @self enthusiasm)
                   (attr @self compassion))))

  (effects
    ; Feed the one-sided attraction scalar: a crush is a strong directed pull.
    ; 0.5 crosses the `fancy` band (0.20) in one fire and sustains ~a year against
    ; the sleep decay (0.938); repeated fires deepen toward `desire` (0.60). The
    ; `fancy` verb-state belief is what courtship (love_match / court) now reads.
    (nudge-stance @self ?victim attraction 0.5)
    ))
