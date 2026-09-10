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
    ; IMAGINED destination: a place @self knows only from a page - an address, no
    ; whereabouts - cannot be planned to. The pipeline arms it for reconciliation (it is
    ; this act's target); the instant identity_by_address fuses it with a place he has
    ; seen, ?dest rebinds to the real one, these two gates fall, and the rungs below take
    ; over. Rooms are only seen from INSIDE, so a room-level address is reached in two
    ; steps: the HOUSE at its premises rung, if he has seen one, is entered - walking in
    ; shows him the rooms; else the region is searched structure by structure until he
    ; has. The search's own /fail record ends the hunt once every structure is seen.
    ; The house is either one @self has SEEN - walk in, and the rooms are learnt - or one he
    ; has not, and the region is searched until he has. COMPLEMENTARY on that, so exactly one
    ; is ever live: the positive is the role that joins the house to the address, and the
    ; negative is a walk, because a (no-role ..) reads the cache alone and cannot join on a
    ; value. The search's own /fail record ends the hunt once every structure is seen.
    (try
      (role ?dest (is-irrealis ?dest) {?dest address ?a} (address-premises ?a): ?pa)
      (role ?house [k building] (observed ?house) {?house address ?pa})
      (role @self (not (spatial @self building ?house)))
      (effects (maintain-proposal {@self enter ?house})))
    (try
      (role ?dest (is-irrealis ?dest) {?dest address ?a} (address-premises ?a): ?pa)
      (when (and (unsubstantial (seen-premises-at ?pa))
                 -{@self find-building ?dest ? /fail}
                 (current-region @self): ?rg))
      (effects (maintain-proposal {@self find-building ?dest ?rg})))
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
