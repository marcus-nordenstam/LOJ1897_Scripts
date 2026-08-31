; ----------------------------------------------------------------------------
; crush_forms (npc-think). A romantic-openness NPC develops a directed
; infatuation toward someone they have met. Feeds the one-sided attraction scalar
; (the `fancy` verb-state belief) - read downstream by appraise_obsession (the
; emotion-driven deliberation branch), by the courtship machinery (love_match /
; court read `fancy`), and by opportunity rules that gate on standing
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

(include "../../../definitions/roles.mc")

(npc-think crush_forms
  (cooldown 1 m)
  (rng-stream incidents)

  ;; @self - a romantically-open single, not already deep in a crush. The trait
  ;; chance (openness x enthusiasm x compassion) gates the receptive crush in
  ;; (when ...) below - a non-belief filter, so it never sits in the role.
  (role @self
              (working-age @self)
              -{@self desire ?}
              -{@self lover ?}
              -{@self spouse ?}
              {@self age-band ?peer_band})
  (role ?victim (any_human ?victim)
                (marriageable-age ?victim)
                ; the crush forms on someone @self has actually met.
                (personally-knows @self ?victim)
                ; No incestuous crush (kin cross-pair believes-macro).
                (none (blood-kin @self ?victim))
                ; Opposite-sex: @self's belief that ?victim's PERCEIVED gender
                ; differs from his own (visible-on-sight -> cacheable).
                -{?victim gender (any {@self gender}).target}
                ; Similar age: @self's band is within ?victim's perceived age-span
                ; (+/-1 band). @self's band is bound in the @self role above - an
                ; inline (any {@self age-band}).target does NOT resolve against the
                ; plural age-span belief, so the band must be a bound variable.
                {?victim age-span ?peer_band})

  ; The trait chance (openness x enthusiasm x compassion) is a non-belief filter,
  ; rolled once per NPC per month in (when) rather than as a role criterion.
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
