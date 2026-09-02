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
    (try
      (role ?room (spatial ?bldg parts [k interior-space room] /env)
                  (not (spatial @self space ?room /env))
                  (!= (bb-read (observe ?room):?obs_room wander-visited) ?w-rel))
      (effects 
        (debug-print "wander proposal: {@self WALK ?obs_room}")
        (maintain-proposal {@self WALK ?obs_room})))
    (try
      (role ?room (spatial ?bldg parts [k interior-space room] /env)
                  (spatial @self space ?room /env))
      (effects (bb-write (observe ?room) wander-visited ?w-rel)))
    (try
      (when (>= (count (every {@self WALK ? /caused_by ?w-rel /succ /ever}))
                (- (count (spatial ?bldg parts [k interior-space room] /env)) 1)))
      (effects 
        (debug-print "@self COMPLETES wander ?bldg")
        (set-outcome ?w-rel /succ)))))
