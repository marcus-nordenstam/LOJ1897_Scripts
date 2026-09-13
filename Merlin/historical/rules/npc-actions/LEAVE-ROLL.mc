; ----------------------------------------------------------------------------
; leave-roll ?roll - THE one dumb membership-strike: drop @self's row from the club roll
; ?roll the proposing task resolved. The twin of JOIN-ROLL. A membership leaves nothing
; behind when it goes - unlike a post, which outlives its holder - so the row goes
; outright. @self ends his own member-of belief think-side once his row is gone.
; ----------------------------------------------------------------------------

(npc-action {@self LEAVE-ROLL ?roll}:?lr-rel
  (duration 15)
  (effects
    (check (spatial ?roll co-located @self))
    (table-remove ?roll member (name @self))
    (set-outcome ?lr-rel /succ)))
