; ----------------------------------------------------------------------------
; wander ?bldg - tour every room of the building he stands in that he has not gone into
; this round. The round's go records ARE the visited memory: they are keyed /caused_by this
; wander, so they scope themselves to it and retire with it.
; ----------------------------------------------------------------------------

(task {@self wander ?bldg}:?wander
  (tar @excl [k container-structure] @object)
  (init
    (check (is-a ?bldg [k container-structure]))
    (check (spatial @self building ?bldg)))
  (and
    ; Standing in the building he looks along its rooms and entrances: a space he has not yet
    ; seen from inside has no mental twin, and it cannot be walked into until it has one.
    (try
      (when (poll (or (< (count (spatial ?bldg parts [k interior-space room]))
                         (count (spatial ?bldg parts [k interior-space room] /env)))
                      (< (count (spatial ?bldg parts [k interior-space entrance]))
                         (count (spatial ?bldg parts [k interior-space entrance] /env))))))
      (effects
        (for-each ?r (spatial ?bldg parts [k interior-space room] /env)
          (observe ?r))
        (for-each ?e (spatial ?bldg parts [k interior-space entrance] /env)
          (observe ?e))))
    (try
      (role ?room (spatial ?bldg parts [k interior-space room])
                  (not (spatial @self space ?room))
                  -{@self go ?room /succ /caused_by ?wander /ever}
                  (select (score (near @self ?room)) (policy roulette unknown-first))
        (effects
          (check (grounded ?room))
          (check (spatial ?room building ?bldg))
          (expect (spatial @self building ?bldg) "wander: touring a building he is not in")
          (maintain-proposal {@self go ?room}))))
    ; Every room but the one he started in has been gone into -> the building is seen.
    (try
      (when (>= (count (every {@self go ? /succ /caused_by ?wander /ever}))
                (- (count (spatial ?bldg parts [k interior-space room] /env)) 1)))
      (effects (set-outcome ?wander /succ)))))
