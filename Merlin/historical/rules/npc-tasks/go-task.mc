; ----------------------------------------------------------------------------
; go - the smart TRAVEL TASK. THE one place that reasons about reaching a destination
; (structure, room, or exterior space). Every lane issues {@self go <dest>} for ANY dest
; and never branches on its kind - the tries dispatch to the primitives (enter / WALK). go
; proposes them as sub-acts (inheriting their body motor). Arrival is go's OWN conclusion (the
; last try), stamped /succ before any minting lane's gate can withdraw it.
;
; and (inclusive): the four tries are a kind-dispatch (structure / room-outside-building /
; room-in-building / exterior), never in competition - exactly one matches per dest.
; ----------------------------------------------------------------------------

(npc-task {@self go ?dest}:?go-rel
  (tar ?)
  (and
    (try
      (role @self (not (spatial @self building ?dest)))
      (when (is-a ?dest [k structure]))
      (effects (maintain-proposal {@self enter ?dest})))
    (try
      (when (and (is-a ?dest [k interior-space])
                 (not (spatial @self building (spatial ?dest building)))))
      (effects (maintain-proposal {@self enter (spatial ?dest building)})))
    (try
      (role @self (not (spatial @self space ?dest)))
      (when (and (is-a ?dest [k interior-space])
                 (spatial @self building (spatial ?dest building))))
      (effects (maintain-proposal {@self WALK ?dest})))
    (try
      (role @self (not (spatial @self space ?dest)))
      (when (is-a ?dest [k exterior-space]))
      (effects (maintain-proposal {@self WALK ?dest})))
    ; ARRIVED: the destination is where @self now is - the task has done its one job.
    (try
      (when (or (and (is-a ?dest [k structure]) (spatial @self building ?dest))
                (spatial @self space ?dest)))
      (effects (set-outcome ?go-rel /succ)))))
