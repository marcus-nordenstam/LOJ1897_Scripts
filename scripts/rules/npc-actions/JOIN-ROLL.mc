; ----------------------------------------------------------------------------
; join-roll ?roll - THE one dumb membership-write: file @self's row onto the club roll
; ?roll the proposing task resolved (perceived at the club's premises). Pen changes
; paper; WHICH roll is the task's decision, handed in on the pattern. A club has MEMBERS,
; so a row is all there is - no vacant line to fill, no post, no rank.
; ----------------------------------------------------------------------------

(npc-action {@self JOIN-ROLL ?roll}:?jr-rel
  (motor body legs)
  (duration (seconds 15 min))
  (effects
    (check (spatial ?roll co-located @self))
    (if (not (table-match (attr ?roll writing) member (name @self)))
        (then (table-add ?roll member (name @self) joined-date (date-now))))
    (set-outcome ?jr-rel /succ)))
