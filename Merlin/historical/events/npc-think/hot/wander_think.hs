
; walk to each room in the building not yet visited during this wander. NO
; (select ...): the role fans one WALK proposal per unvisited room and the
; action pipeline is the iterator - it promotes one WALK at a time, arrival
; vetoes that room's activation (withdrawing its proposal), and the next WALK
; promotes. The visited mark is VALUED with the wander instance ?w: a mark
; from an older round mismatches and reads unvisited, so a fresh round
; re-tours with no clearing, and a resumed round (same ?w) keeps its progress.
(npc-think wander_go
  (task {@self wander ?bldg}:?w)
  (role ?room (env-parts ?bldg [k interior_space room])
              (not (at_location @self ?room))
              (not (= (bb-read ?room wander-visited) ?w)))
  (effects (debug-print "WANDER_GO room=?room")
           (maintain-proposal {@self WALK ?room})))

; mark each room you visit
(npc-think wander_mark
  (task {@self wander ?bldg}:?w)
  (role ?room (env-parts ?bldg [k interior_space room])
              (at_location @self ?room))
  (effects (bb-write ?room wander-visited ?w)))

; a completed WALK record exists for every room but the one the round started
; in (standing there covered it) -> concluded.
(npc-think wander_done
  (task {@self wander ?bldg}:?w)
  (when (>= (count (every {@self WALK ? /caused_by ?w /succ /ever}))
            (- (count (env-parts ?bldg [k interior_space room])) 1)))
  (effects
      (debug-print "WANDER_DONE")
      (set-outcome ?w succ)))
