; ----------------------------------------------------------------------------
; putter - the monthly home round. It no longer walks the rooms or reads mail itself: the
; room-walk is the general `wander` task (putter proposes ONE), and mail is `read-mail` on
; its own cadence. What remains bespoke is discovering / re-checking the hiding-spot caches
; in each room the wander carries @self through. The want_putter driver stays in
; putter_think.hs.
;
;   wander : begin ONE wander of home (walks every known room).
;   cache  : CHORE - in a room this round -> discover / re-check its caches.
;   done   : the wander concluded -> end.
; ----------------------------------------------------------------------------

(npc-task {@self putter ?home}:?p-rel
  (tar structure)
  (and
    (try
      (when -{@self wander ?home /caused_by ?p-rel /ever})
      (utility idle)
      (effects (begin-proposal {@self wander ?home})))
    (try
      (when (and (spatial @self space): ?room
                 (spatial @self building ?home)))
      (effects
        (for-each ?cache (spatial ?room parts [k interior-space hiding-spot] /env)
          (if -{@self hiding-spot ?cache}
              (then
                (if (chance (* 0.006 (+ 1.0 (attr @self openness))))
                    (then
                      (begin-belief {@self hiding-spot (internalize ?cache)})
                      (observe (spatial ?cache contents /env)))))
              (else (observe (spatial ?cache contents /env)))))))
    (try
      (when {@self wander ?home /succ /caused_by ?p-rel})
      (effects (set-outcome ?p-rel /succ)))))
