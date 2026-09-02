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
                 (not (spatial @self building ?dest))))
      (effects (maintain-proposal {@self enter ?dest})))
    (try
      (when (and (is-a ?dest [k interior-space])
                 (not (spatial @self building (spatial ?dest building)))))
      (effects (maintain-proposal {@self enter (spatial ?dest building)})))
    (try
      (when (and (is-a ?dest [k interior-space])
                 (spatial @self building (spatial ?dest building))
                 (not (spatial @self space ?dest))))
      (effects (maintain-proposal {@self WALK ?dest})))
    (try
      (when (and (is-a ?dest [k exterior-space])
                 (not (spatial @self space ?dest))))
      (effects (maintain-proposal {@self WALK ?dest})))))
