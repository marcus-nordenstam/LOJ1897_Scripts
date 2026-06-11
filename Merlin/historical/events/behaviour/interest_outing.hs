; ----------------------------------------------------------------------------
; Interest activity lane (see Docs/hsim/hsim_social.md "Co-presence and
; activity lanes"). An NPC who
; holds an interest pursues it - going to the theatre for music / theatre, the
; church for religion / spiritualism, the pub for everything else (the
; universal society / discussion venue, no dedicated lecture-hall kind exists
; yet). Each pursuit records the episodic memory {@self pursue <venue> /aux
; <domain>}; the (venue, date) it lands on is the substrate the co-presence
; sweep reads.
;
; Group-vs-individual is decided INSIDE the effect (pursue-interest), per-mind
; (core principle 2): role-0 enumerates candidates; the effect reads the
; organizer's own interests + ties from its mind. If the organizer KNOWS enough
; co-enthusiasts among its ties (its flat {tie interest domain} believe-about
; knowledge) it convenes them; otherwise it pursues solo and the venue's
; co-presence sweep discovers fellow enthusiasts who crossed its path - so two
; solo enthusiasts who meet learn they share the interest and can convene next
; cycle (the discovery bootstrap, section 6).
;
; The (chance) is openness-weighted jitter on top of the structural gate (holds
; at least one interest): the curious pursue their interests often, the
; closed-off rarely. Fires monthly on the active-day bag (L0).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event interest_outing
  (nl         "?ego pursues an interest")
  (kind       _interest_outing)
  (schedule   (monthly))
  (band      afternoon)
  (rng-stream behaviour)

  (roles
    (role ?ego (template any_human)
               (>= (years-old ?self) 12)
               (believes ?self {@self interest ?})
               (chance (* 0.4 (+ 0.3 (attr ?self openness))))))

  (when (alive ?ego))

  (effects
    (pursue-interest ?ego)
    (log _interest_outing ?ego)))
