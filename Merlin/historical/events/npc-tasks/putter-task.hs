; ----------------------------------------------------------------------------
; putter - the monthly home round. It no longer walks the rooms or reads mail itself: the
; room-walk is the general `wander` task (putter proposes ONE), and mail is `read_mail` on
; its own cadence. What remains bespoke is discovering / re-checking the hiding-spot caches
; in each room the wander carries @self through. The want_putter driver stays in
; putter_think.hs.
;
;   wander : begin ONE wander of home (walks every known room).
;   cache  : CHORE - in a room this round -> discover / re-check its caches.
;   done   : the wander concluded -> end.
; ----------------------------------------------------------------------------

(npc-task {@self putter ?home}:?p
  (tar structure)
  (and
    (try
      (when (none {@self wander ?home /caused_by ?p /ever}))
      (utility idle)
      (effects (begin-proposal {@self wander ?home})))
    (try
      (when (and (location @self): ?room
                 (in-building @self ?home)))
      (effects
        (for-each ?cache (spatial ?room parts [k interior_space hiding_spot] /env)
          (if (none {@self hiding_spot ?cache})
              (then
                (if (chance (* 0.006 (+ 1.0 (attr @self openness))))
                    (then
                      (begin-belief {@self hiding_spot (internalize ?cache)})
                      (read-cache ?cache))))
              (else (read-cache ?cache))))))
    (try
      (when (believes {@self wander ?home /succ /caused_by ?p}))
      (effects (set-outcome ?p succ)))))
