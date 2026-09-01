; ----------------------------------------------------------------------------
; court (npc-think) - respectable courtship: building reciprocal fancy.
;
; A suitor who already FANCIES a specific person pays them court, and the
; attention GROWS THE BELOVED'S ATTRACTION toward the suitor - the road to
; reciprocal fancy and a love_match marriage. Courtship leads to FANCY, never a
; lover bond: becoming lovers BEFORE marriage is the seduction / fallen-woman
; path, which respectable courtship deliberately avoids. So this rule only
; nudges the attraction stance - love_match reads that fancy to marry the pair.
;
; A mental change (the beloved's attraction grows), so npc-think. RELATIONAL: the
; suitor courts the SPECIFIC person he fancies (the cross-pair `fancy` bitset),
; not whoever shares a venue - a particular pair rarely coincides physically, so
; (like all courtship FORMATION) it is keyed on the standing attraction, not
; co-presence (the settled reversion; the place-lane errand-magnetism form is a
; future refinement). Fired by the per-NPC emergent pass MONTHLY; the per-suitor
; (chance) paces repeated courting.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think court
  (cooldown 1 m)
  (rng-stream marriages)

  ; @self the suitor must ALREADY fancy someone and be a marriageable single -
  ; courtship is the directed pursuit of a specific crush, not a random advance.
  (role @self 
              (marriageable-age @self)
              -{@self spouse ?}
              -{@self fiancee ?}
              {@self fancy ?})
  ;; SELF-POV (telepathy purge CAT-3): the suitor reads the beloved from his OWN
  ;; knowledge - her marital state / lover / fallen mark as HE knows them
  ;; (permissive on the unknown), and her receptivity as SHE has signalled it to
  ;; him (confess_fancy). No cross-mind read.
  (role ?beloved (any_human ?beloved)
                (marriageable-age ?beloved)
                -{?beloved spouse ?}
                -{?beloved fiancee ?}
                ; You do not court a TAKEN or FALLEN woman: a lover bond means
                ; she is spoken-for or compromised, and the fallen-woman mark is
                ; the ruined maiden a respectable suitor abandons. (As @self knows
                ; them - he courts on; a secret he has not heard does not stop him.)
                -{?beloved lover ?}
                -{?beloved prototype fallen-woman}
                ; the specific person @self is attracted to (the attraction
                ; stance has reached at least the `fancy` band, read as the
                ; explicit band-ladder verb-state belief) ...
                (is-attracted-to @self ?beloved)
                ; RECEPTIVITY: courting only sways an AVAILABLE heart - she has
                ; TOLD HIM she fancies him (deepening), or - as far as HE knows -
                ; she fancies NO ONE yet (winnable). A girl HE KNOWS to fancy
                ; another is not courted - that rival suitor has been heard of.
                (or {?beloved fancy @self}
                    -{?beloved fancy ?})
                ; opposite-sex: @self's belief that the beloved's PERCEIVED gender
                ; differs from his own (visible-on-sight -> cacheable). And not kin.
                -{?beloved gender (any {@self gender}).target}
                (none (blood-kin @self ?beloved))
                ; Court the ONE the suitor is most drawn to - "the directed pursuit of a
                ; specific crush", so the fan-out reduces to the strongest attraction.
                (select (score (stance-band ?beloved attraction)) (policy argmax)))

  ; The per-suitor (chance) that paces repeated courting is not a belief query,
  ; so it gates the fire here rather than filtering the role.
  (when (chance 0.5))

  (effects
    ; Attention from her suitor grows her attraction toward him (reciprocal fancy
    ; builds over repeated courting), so a one-sided crush becomes the MUTUAL fancy
    ; love_match marries. 0.25 per courting clears the fancy band (0.20) in
    ; one-to-two passes, comfortably ahead of the sleep decay.
    ; TELEPATHY - a rule cannot move ANOTHER mind's stance. Restore this as the other
    ; party's own reflex on the act. Commented out pending that redesign.
    ; (nudge-stance ?beloved @self attraction 0.25)
    ; ... and courting keeps @self's OWN ardour alive: an actively-courting suitor
    ; stays keen, so his fancy does not decay below the band before the pair reach
    ; love_match.
    (nudge-stance ?beloved attraction 0.10)
    ))
