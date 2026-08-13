; ----------------------------------------------------------------------------
; putter - the monthly home round. It no longer walks the rooms or reads mail
; itself: the room-walk is the general `wander` task (putter proposes ONE), and mail
; is the `read_mail` lane on its own daily cadence. What remains bespoke to puttering
; is discovering / re-checking the hiding-spot caches in each room the wander carries
; @self through.
;
;   want_putter   : monthly, at home -> begin a putter round.
;   putter_wander : begin ONE wander of home (walks every known room).
;   putter_cache  : CHORE - in a room this round -> discover / re-check its caches.
;   putter_done   : the wander concluded -> end.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think want_putter
  (lock-rule)
  (cooldown 1 m)
  (role ?home {@self home ?home})
  (when (in-building @self ?home))
  (utility 40)
  (effects (begin-proposal {@self putter ?home})))

(npc-think putter_wander
  (task {@self putter ?home}:?p)
  (when (none {@self wander ?home /caused_by ?p /ever}))
  (utility 41)
  (effects (begin-proposal {@self wander ?home})))

; CHORE - hiding-spot caches: for each cache in the room @self is puttering in,
; either DISCOVER it (if @self does not know it) or RE-CHECK it (if @self does).
(npc-think putter_cache
  (task {@self putter ?home})
  (when (and (location @self): ?room
             {?home room ?room}))
  (effects
    (for-each ?cache (attr-values ?room parts [k interior_space hiding_spot])
      (if (none {@self hiding_spot ?cache})
          (then
            (if (chance (* 0.006 (+ 1.0 (attr @self openness))))
                (then
                  (begin-belief {@self hiding_spot (internalize ?cache)})
                  (read-cache ?cache))))
          (else (read-cache ?cache))))))

(npc-think putter_done
  (task {@self putter ?home}:?p)
  (when (believes {@self wander ?home /succ /caused_by ?p}))
  (effects (set-outcome ?p succ)))
