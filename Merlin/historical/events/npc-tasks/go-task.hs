; ----------------------------------------------------------------------------
; go - the smart TRAVEL TASK. THE one place that reasons about reaching a destination
; (structure, room, or exterior space). Every lane issues {@self go <dest>} for ANY dest
; and never branches on its kind - the tries dispatch to the primitives (enter / WALK). go
; proposes them as sub-acts (inheriting their body motor); arrival is the minting lane's
; own gate, so go needs no outcome try (like enter).
;
; and (inclusive): the four tries are a kind-dispatch (structure / room-outside-building /
; room-in-building / exterior), never in competition - exactly one matches per dest.
; ----------------------------------------------------------------------------

(npc-task {@self go ?dest}
  (tar ?)
  (and
    (try
      (when (and (is-a ?dest [k structure])
                 (not (in-building @self ?dest))))
      (effects (maintain-proposal {@self enter ?dest})))
    (try
      (when (and (is-a ?dest [k interior_space])
                 (not (in-building @self (building ?dest)))))
      (effects (maintain-proposal {@self enter (building ?dest)})))
    (try
      (when (and (is-a ?dest [k interior_space])
                 (in-building @self (building ?dest))
                 (not (at_location @self ?dest))))
      (effects (maintain-proposal {@self WALK ?dest})))
    (try
      (when (and (is-a ?dest [k exterior_space])
                 (not (at_location @self ?dest))))
      (effects (maintain-proposal {@self WALK ?dest})))))
