; ----------------------------------------------------------------------------
; court - respectable courtship (place-and-time reframe, Section 4).
;
; A suitor who already FANCIES a specific person seeks them out (errand
; magnetism places the suitor at a public venue the beloved attends) and courts
; them. Courting GROWS THE BELOVED'S ATTRACTION toward the suitor - the
; place-pure road to reciprocal fancy and a love_match marriage.
;
; Courtship leads to FANCY, never a lover bond. Becoming lovers BEFORE marriage
; is the fallen-woman / seduction outcome (seduce -> lover, an extramarital /
; reckless-seduction path), which respectable courtship deliberately avoids. So
; this event only nudges the attraction stance - the love_match machinery reads
; that fancy to marry the pair.
;
; Fired by the `court` affordance (pub / restaurant / theatre / church /
; sports_ground / social_clubhouse) via resolve_affordances: the suitor is the
; co-present actor, the beloved is the fancied person who is co-present this
; band. NOT on the DES (place-lane - suppressed in seed_queue).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event court
  (nl         "?suitor courts ?beloved")
  (kind       _court)
  ; EMERGENT (Section 4.11): no (schedule) - fired by the `court` affordance via
  ; resolve_affordances (place-lane); the suitor is the co-present actor.
  (band      evening)
  (rng-stream marriages)

  (roles
    ; The suitor (role[0], preset from the venue's occupants) must ALREADY fancy
    ; someone and be a marriageable single - courtship is the directed pursuit of
    ; a specific crush, not a random advance.
    (role ?suitor (template any_human)
                  (>= (years-old ?suitor) 16)
                  (not (believes ?suitor {@self spouse ?}))
                  (not (believes ?suitor {@self fiancee ?}))
                  (believes ?suitor {@self fancy ?}))
    (role ?beloved (template any_human)
                  (not (= ?beloved ?suitor))
                  (>= (years-old ?beloved) 16)
                  (not (believes ?beloved {@self spouse ?}))
                  (not (believes ?beloved {@self fiancee ?}))
                  ; You do not court a TAKEN or FALLEN woman: a lover bond means
                  ; she is spoken-for or compromised (seduce -> lover), and the
                  ; fallen-woman mark is the ruined maiden a respectable suitor
                  ; abandons. (Both stop the suitor courting her - scenario (c).)
                  (not (believes ?beloved {@self lover ?}))
                  (not (believes ?beloved {@self prototype fallen_woman}))
                  ; the specific person the suitor fancies (cross-pair bitset) ...
                  (stance-at-least ?suitor ?beloved fancy)
                  ; ... who is actually co-present this band (errand magnetism
                  ; brought the suitor to where she is).
                  (co-present ?suitor ?beloved)
                  ; RECEPTIVITY: courting only sways an AVAILABLE heart - she
                  ; already fancies HIM (deepening), or she fancies NO ONE yet
                  ; (winnable). A girl who already fancies ANOTHER is not courted
                  ; away - that rival suitor loses (scenario (b)).
                  (or (believes ?beloved {@self fancy ?suitor})
                      (not (believes ?beloved {@self fancy ?})))
                  ; opposite-sex (attr read, gates reliably) and not kin.
                  (not (= (attr ?beloved gender) (attr ?suitor gender)))
                  (not (kin ?suitor ?beloved))))

  (effects
    ; Attention from a suitor she is co-present with grows her attraction toward
    ; him (reciprocal fancy builds over repeated courting), so a one-sided crush
    ; becomes the MUTUAL fancy love_match marries. 0.25 per courting clears the
    ; fancy band (0.20) in one-to-two meetings, comfortably ahead of the sleep
    ; decay - so a persistent suitor reliably wins an available heart.
    (nudge-stance ?beloved ?suitor attraction 0.25)
    ; ... and courting keeps the SUITOR'S OWN ardour alive: an actively-courting
    ; man stays keen, so his fancy does not decay below the band before the
    ; annual love_match tick (otherwise a year-old crush fades and the mutual
    ; pair misses the wedding even though she reciprocated).
    (nudge-stance ?suitor ?beloved attraction 0.10)
    (log _court ?suitor)))
