; ----------------------------------------------------------------------------
; family_dinner (npc-think). The household head gathers the co-resident family
; (spouse + children + parents) for a meal where news travels: the
; (family-dinner ?actor) effect spreads BOTH gossip (the top thing the actor
; knows about a third party) and catch-up (the actor's own recent news) around
; the table - but NOT confide (you do not air private secrets at the family
; table). Family is naturally small (< 6), so the spread self-caps; the rumour
; carries outward as each member next dines with their OWN family, a household at
; a time.
;
; A mental change (news lands with the household), so npc-think. Gated on having
; a spouse (the canonical household head); single / widowed members still spread
; news through gossip / catch_up. Fired by the per-NPC emergent pass, MONTHLY.
; The co-resident family is genuinely co-present (they share the home), so unlike
; the other conversation lanes the relay's reach IS a physical household - the
; (family-dinner) verb walks the actor's kin, not an arbitrary circle.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event family_dinner
  (sim-window-start)
  (nl         "@self's family gathers for dinner")
  (rng-stream behaviour)

  (roles
    (role @self (template any_human)
                (>= (years-old @self) 18)
                (believes @self {@self spouse ?})
                (chance 0.4)))

  (effects
    (family-dinner @self)
    (log _family_dinner @self)))
