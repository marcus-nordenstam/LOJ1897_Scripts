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

; COVERAGE is private-bb scratch VALUED with the wander instance ?w: a mark from
; an older instance mismatches ?w and reads unvisited automatically - no clears,
; no record scoping, and an interrupted-and-resumed round keeps its progress
; (the /caused_by-scoped go-record design lost ALL coverage on every re-instance
; and a busy mind never finished a pass). Standing in a room marks it - the
; start room included - and the first mark of a round seeds the pending count.
(npc-think wander_mark
  (task {@self wander ?bldg}:?w)
  (role ?room (parts ?bldg [k interior_space room])
        (at_location @self ?room)
        (not (= (bb-read ?room wander-visited) ?w)))
  (effects
    ; pending seeds from ENV-PARTS (ALL rooms), not parts (observed) - else the
    ; round concludes as soon as the ALREADY-KNOWN rooms are marked and never
    ; drives explore to the UNOBSERVED ones, so a resident who has stood in only
    ; his kitchen never reaches the hallway where his mail pile sits.
    (if (not (= (bb-read ?bldg wander-round) ?w))
        (then (bb-write ?bldg wander-round ?w)
              (bb-write ?bldg wander-pending
                        (count (env-parts ?bldg [k interior_space room])))))
    (bb-write ?room wander-visited ?w)
    (bb-write ?bldg wander-pending (- (bb-read ?bldg wander-pending) 1))))

; all rooms known (no explore still running) -> walk to each room not yet
; visited THIS round, one at a time (arrival marks it via wander_mark).
(npc-think wander_go
  (task {@self wander ?bldg}:?w)
  ; KNOWN rooms come from the belief-honest (parts) op (env structure filtered to
  ; what @self has observed) - room beliefs are engine-written, never pattern-read.
  (role ?room (parts ?bldg [k interior_space room])
        (not (= (bb-read ?room wander-visited) ?w))
        (not (at_location @self ?room))
        (select (policy first-match)))
  (when (none {@self explore ?bldg /pres}))
  (effects (debug-print "WANDER_GO room=?room")
           (maintain-proposal {@self WALK ?room})))

; every known room visited this round -> concluded.
(npc-think wander_done
  (task {@self wander ?bldg}:?w)
  (when (and (= (bb-read ?bldg wander-round) ?w)
             (= (bb-read ?bldg wander-pending) 0)))
  (effects (debug-print "WANDER_DONE") (set-outcome ?w succ)))
