; ----------------------------------------------------------------------------
; Family dinner. The household head gathers the co-resident family (spouse +
; children + parents) for a meal where news travels: the (family-dinner ?actor)
; effect spreads BOTH gossip (the top thing the actor knows about a third party)
; and catch-up (the actor's own recent news) around the table - but NOT confide
; (you do not air private secrets at the family table). Family is naturally
; small (< 6), so the spread self-caps; the rumour carries outward as each
; member next dines with their OWN family, a household at a time.
;
; Gated on having a spouse (the canonical household head); single / widowed
; members still spread news through gossip / catch_up. EMERGENT (Section 4.11):
; no (schedule) - fired by the `family_dinner` affordance at the home when the
; co-resident family is present (place-lane, suppressed from the DES).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event family_dinner
  (nl         "?actor's family gathers for dinner")
  (kind       _family_dinner)
  (band      evening)
  (rng-stream behaviour)

  (roles
    (role ?actor (template any_human)
                 (>= (years-old ?self) 18)
                 (believes ?self {@self spouse ?})
                 (chance 0.4)))

  (when (alive ?actor))

  (effects
    (family-dinner ?actor)
    (log _family_dinner ?actor)))
