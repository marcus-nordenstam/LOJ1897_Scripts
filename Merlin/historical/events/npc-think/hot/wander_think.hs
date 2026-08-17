; ----------------------------------------------------------------------------
; wander ?bldg - step through a building's KNOWN rooms, one at a time, once per
; wander. The walk reads ONLY beliefs ({?bldg room ?room}); it is putter's monthly
; round generalised off home to any building, so a lane that needs @self to have
; stood in every room (find the mail stack, refresh a room's contents, check every
; cache) proposes ONE wander.
;
; If @self's room-knowledge is incomplete, wander first learns the rooms: while any
; room of ?bldg is still unobserved it maintains `explore ?bldg` (whose frontier walk
; teaches them), and only walks the known rooms once discovery is done. Concluded when
; every known room has been walked this wander.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; knowledge incomplete -> learn the rooms. The frontier role binds while an unobserved
; room of ?bldg remains, driving the maintain; it evaporates once all are observed.
(npc-think wander_explore
  (task {@self wander ?bldg})
  (role ?room (env-parts ?bldg [k interior_space room])
        (not (observed ?room))
        (select (policy first-match)))
  (effects (maintain-proposal {@self explore ?bldg})))

; all rooms known (no explore still running) -> walk each known room not yet walked
; this wander, one at a time.
(npc-think wander_go
  (task {@self wander ?bldg}:?w)
  ; KNOWN rooms come from the belief-honest (parts) op (env structure filtered to
  ; what @self has observed) - room beliefs are engine-written, never pattern-read.
  (role ?room (parts ?bldg [k interior_space room])
        (none {@self go ?room /past /caused_by ?w})
        (select (policy first-match)))
  (when (none {@self explore ?bldg /pres}))
  (effects (maintain-proposal {@self WALK ?room})))

; walked every known room this wander -> concluded.
(npc-think wander_done
  (task {@self wander ?bldg}:?w)
  (when (>= (count (every {@self go ? /past /caused_by ?w}))
            (count (parts ?bldg [k interior_space room]))))
  (effects (set-outcome ?w succ)))
