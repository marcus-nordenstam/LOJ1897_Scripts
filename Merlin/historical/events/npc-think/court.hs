; ----------------------------------------------------------------------------
; court (npc-think) - respectable courtship: building reciprocal fancy.
;
; A suitor who already FANCIES a specific person pays them court, and the
; attention GROWS THE BELOVED'S ATTRACTION toward the suitor - the road to
; reciprocal fancy and a love_match marriage. Courtship leads to FANCY, never a
; lover bond: becoming lovers BEFORE marriage is the seduction / fallen-woman
; path, which respectable courtship deliberately avoids. So this event only
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

(include "../../definitions/roles.hs")

(hsim-event court
  (sim-window-start)
  (nl         "@self courts ?beloved")
  (rng-stream marriages)

  (roles
    ; @self the suitor must ALREADY fancy someone and be a marriageable single -
    ; courtship is the directed pursuit of a specific crush, not a random advance.
    (role @self (template any_human)
                (>= (years-old @self) 16)
                (not (believes {@self spouse ?}))
                (not (believes {@self fiancee ?}))
                (believes {@self fancy ?})
                (chance 0.5))
    (role ?beloved (template any_human)
                  (not (= ?beloved @self))
                  (>= (years-old ?beloved) 16)
                  (not (believes ?beloved {@self spouse ?}))
                  (not (believes ?beloved {@self fiancee ?}))
                  ; You do not court a TAKEN or FALLEN woman: a lover bond means
                  ; she is spoken-for or compromised, and the fallen-woman mark is
                  ; the ruined maiden a respectable suitor abandons.
                  (not (believes ?beloved {@self lover ?}))
                  (not (believes ?beloved {@self prototype fallen_woman}))
                  ; the specific person @self fancies (cross-pair bitset) ...
                  (stance-at-least @self ?beloved fancy)
                  ; RECEPTIVITY: courting only sways an AVAILABLE heart - she
                  ; already fancies HIM (deepening), or she fancies NO ONE yet
                  ; (winnable). A girl who already fancies ANOTHER is not courted
                  ; away - that rival suitor loses.
                  (or (believes ?beloved {?beloved fancy @self})
                      (not (believes ?beloved {?beloved fancy ?})))
                  ; opposite-sex (attr read, gates reliably) and not kin.
                  (not (= (attr ?beloved gender) (attr @self gender)))
                  (not (kin @self ?beloved))))

  (effects
    ; Attention from her suitor grows her attraction toward him (reciprocal fancy
    ; builds over repeated courting), so a one-sided crush becomes the MUTUAL fancy
    ; love_match marries. 0.25 per courting clears the fancy band (0.20) in
    ; one-to-two passes, comfortably ahead of the sleep decay.
    (nudge-stance ?beloved @self attraction 0.25)
    ; ... and courting keeps @self's OWN ardour alive: an actively-courting suitor
    ; stays keen, so his fancy does not decay below the band before the pair reach
    ; love_match.
    (nudge-stance @self ?beloved attraction 0.10)
    (log _court @self)))
