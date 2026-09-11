; ----------------------------------------------------------------------------
; go - the smart TRAVEL TASK. THE one place that reasons about reaching a destination
; (structure, room, or exterior space). Every lane issues {@self go <dest>} for ANY dest
; and never branches on its kind - the tries dispatch to the primitives (enter / WALK). go
; proposes them as sub-acts (inheriting their body motor). Arrival is go's OWN conclusion (the
; last try), stamped /succ before any minting lane's gate can withdraw it.
;
; The dispatch turns on (unplaced ?dest) - "@self cannot route to this place" - and its
; complement. A place he cannot route to is FOUND first (three rungs, complementary on what
; he has seen); one he can is reached (three rungs, complementary on its kind and where he
; stands). unplaced asks a room and a structure different questions because the primitives
; reach them differently; funcs/spatial.mc carries the why.
;
; The reads LIVE IN THE (when ..) - so does @self's own position - because only the gates
; re-run while an activation holds, and both flip mid-journey. In a role they would be
; decided once at admission and the unplaced rungs would keep proposing an approach he has
; already completed. The handoff from unplaced to placed is emergent, exactly as enter's
; threshold -> interior handoff is.
;
; and (inclusive): the rungs are a dispatch, never a competition.
; ----------------------------------------------------------------------------

(npc-task {@self go ?dest}:?go-rel
  (tar ?)
  (and
    ; UNPLACED, and the house at its premises is one @self HAS seen: walk in. A room is
    ; only ever seen from INSIDE a building, so entering is what places it - and an address
    ; is the only thing a page can carry about a place.
    (try
      (role ?dest {?dest address ?a} (address-premises ?a): ?pa)
      (role ?house [k building] (observed ?house) {?house address ?pa})
      (when (and (unplaced ?dest)
                 (not (spatial @self building ?house))))
      (effects (maintain-proposal {@self enter ?house})))
    ; UNPLACED and already INSIDE that house: walking in taught him the entrance, not every
    ; room. Tour it until the room itself is placed, which drops this rung and raises the
    ; WALK below.
    (try
      (role ?dest {?dest address ?a} (address-premises ?a): ?pa)
      (role ?house [k building] (observed ?house) {?house address ?pa})
      (when (and (unplaced ?dest)
                 (spatial @self building ?house)))
      (effects (maintain-proposal {@self locate ?dest ?house})))
    ; UNPLACED and no house he has seen stands at that premises: search the region
    ; structure by structure until one does. The search's own /fail record ends the hunt
    ; once every structure is seen.
    (try
      (role ?dest {?dest address ?a} (address-premises ?a): ?pa)
      (when (and (unplaced ?dest)
                 (unsubstantial (seen-premises-at ?pa))
                 -{@self find-building ?dest ? /fail}
                 (current-region @self): ?rg))
      (effects (maintain-proposal {@self find-building ?dest ?rg})))

    ; A REAL structure is walked to whether or not @self has seen it - enter takes it from
    ; the world's own geometry. Only an imagined one has no face to stand at, and that is
    ; what (unplaced ..) excludes here.
    (try
      (when (and (is-a ?dest [k structure])
                 (not (unplaced ?dest))
                 (not (spatial @self building ?dest))))
      (effects (maintain-proposal {@self enter ?dest})))
    ; A ROOM is reached through the building @self knows it sits in. The bind IS the guard:
    ; an @unknown gates the rung false, so no rung can mint (enter @unknown) - and a move
    ; act on a place nobody can point to walks the body to the world origin for good.
    (try
      (when (and (is-a ?dest [k interior-space])
                 (spatial ?dest building): ?bldg
                 (not (spatial @self building ?bldg))))
      (effects (maintain-proposal {@self enter ?bldg})))
    (try
      (when (and (is-a ?dest [k interior-space])
                 (spatial ?dest building): ?bldg
                 (spatial @self building ?bldg)
                 (not (spatial @self space ?dest))))
      (effects (maintain-proposal {@self WALK ?dest})))
    ; An outdoor space is walked to and is contained by no building.
    (try
      (when (and (is-a ?dest [k exterior-space])
                 (not (spatial @self space ?dest))))
      (effects (maintain-proposal {@self WALK ?dest})))
    ; ARRIVED: the destination is where @self now is - the task has done its one job.
    (try
      (when (or (and (is-a ?dest [k structure]) (spatial @self building ?dest))
                (spatial @self space ?dest)))
      (effects (set-outcome ?go-rel /succ)))))
