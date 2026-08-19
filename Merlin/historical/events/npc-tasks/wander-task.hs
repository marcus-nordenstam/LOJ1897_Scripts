; ----------------------------------------------------------------------------
; wander - tour every room of a building not yet visited this round. The head binds
; ?bldg and captures the wander instance :?w; the visited mark is VALUED with ?w, so a
; mark from an older round reads unvisited (a fresh round re-tours with no clearing, a
; resumed round keeps its progress).
;
; INCLUSIVE (and ...): the three tries co-fire - walk toward unvisited rooms, mark the
; room you are standing in, and conclude when the round is covered - they are not a
; partition. NO (select ...): the go role fans one WALK proposal per unvisited room and
; the action pipeline is the iterator (promote one WALK, arrival vetoes that room, next
; WALK promotes).
; ----------------------------------------------------------------------------

(npc-task {@self wander ?bldg}:?w
  (tar @excl structure)
  (and
    (try
      (role ?room (spatial ?bldg parts [k interior_space room] /env)
                  (not (spatial @self space ?room))
                  (not (= (bb-read ?room wander-visited) ?w)))
      (effects (debug-print "WANDER_GO room=?room")
               (maintain-proposal {@self WALK ?room})))
    (try
      (role ?room (spatial ?bldg parts [k interior_space room] /env)
                  (spatial @self space ?room))
      (effects (bb-write ?room wander-visited ?w)))
    (try
      (when (>= (count (every {@self WALK ? /caused_by ?w /succ /ever}))
                (- (count (spatial ?bldg parts [k interior_space room] /env)) 1)))
      (effects (debug-print "WANDER_DONE")
               (set-outcome ?w succ)))))
