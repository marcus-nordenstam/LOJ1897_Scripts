; ----------------------------------------------------------------------------
; wander - tour every room of a building not yet visited this round. The head binds
; ?bldg and captures the wander instance :?w-rel; the visited mark is VALUED with ?w-rel, so a
; mark from an older round reads unvisited (a fresh round re-tours with no clearing, a
; resumed round keeps its progress).
;
; INCLUSIVE (and ...): the three tries co-fire - walk toward unvisited rooms, mark the
; room you are standing in, and conclude when the round is covered - they are not a
; partition. NO (select ...): the go role fans one WALK proposal per unvisited room and
; the action pipeline is the iterator (promote one WALK, arrival vetoes that room, next
; WALK promotes).
; ----------------------------------------------------------------------------

(npc-task {@self wander ?bldg}:?w-rel
  (tar @excl structure)
  (and
    ; A room of ?bldg I am not standing in and have not already walked to during THIS
    ; wander. The WALK act records ARE the visited memory - keyed /caused_by this wander, so
    ; they scope themselves to it and retire with it. No marker to write: the old form kept a
    ; per-room `wander-visited` blackboard entry, and had to (observe ?room) inside the FILTER
    ; to mint the mind-local symbol the bb was keyed on - a MUTATION in a role filter, paid
    ; once per candidate (measured: ~1.2M observes in a 2yr run, against 1712 fires).
    ;
    ; ?room is an ENV symbol (the /env parts walk), and that is exactly what the negative
    ; wants: an unobserved room has no mental twin, the criteria degenerate, the search finds
    ; nothing and -{..} holds - so a room he has never been in always survives. The PROPOSAL
    ; is the one place the mental symbol is required (a belief target may not be an env
    ; symbol - it mints {@self WALK @fail}), so the observe happens there, on the fire, once.
    (try
      (role ?room (spatial ?bldg parts [k interior-space room] /env)
                  (not (spatial @self space ?room /env))
                  -{@self WALK ?room /caused_by ?w-rel /ever})
      (effects
        (observe ?room): ?obs-room
        (maintain-proposal {@self WALK ?obs-room})))
    ; Every room but the one he started in has been walked -> the building is seen.
    (try
      (when (>= (count (every {@self WALK ? /caused_by ?w-rel /past /ever}))
                (- (count (spatial ?bldg parts [k interior-space room] /env)) 1)))
      (effects (set-outcome ?w-rel /succ)))))
