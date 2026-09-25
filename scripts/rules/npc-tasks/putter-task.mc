; ----------------------------------------------------------------------------
; putter - the monthly home round. It no longer walks the rooms or reads mail itself: the
; room-walk is the general `wander` task (putter proposes ONE), and mail is `read-mail` on
; its own cadence. What remains bespoke is discovering / re-checking the hiding-spot caches
; in each room the wander carries @self through. The want_putter driver stays in
; putter_think.mc.
;
;   wander : MAINTAIN one wander of home (walks every known room) until it succeeds - an
;            interrupted putter withdraws it, a resumed putter mints it fresh.
;   cache  : CHORE - in a room this round -> discover / re-check its caches.
;   done   : the wander concluded -> end.
; ----------------------------------------------------------------------------

(npc-task {@self putter ?home}:?p-rel
  (tar [k structure] @object)
  (and
    (try
      (role @self -{@self wander ?home /succ /caused_by ?p-rel}
        (utility idle)
        (effects (maintain-proposal {@self wander ?home}))))
    (try
      (when (and (spatial @self space): ?room
                 (spatial @self building ?home)))
      (effects
        (for-each ?cache (spatial ?room parts [k interior-space hiding-spot] /env)
          (if -{@self hiding-spot ?cache}
              (then
                (if (chance (* 0.006 (+ 1.0 (target-or @self openness 0.0))))
                    (then
                      (begin-belief {@self hiding-spot (internalize ?cache)})
                      (for-each ?item (spatial ?cache contents /env)
                        (observe ?item)))))
              (else
                (for-each ?item (spatial ?cache contents /env)
                  (observe ?item)))))))
    ; STOPGAP (npc-actions/STOCK-LARDER.mc): the supply run never reaches the shop, so a
    ; resident standing in his own empty kitchen stocks it himself. Delete with that file.
    (try
      (when (and (spatial @self building ?home)
                 (spatial ?home room [k kitchen]): ?kitchen
                 (spatial @self space ?kitchen)
                 (= (believed-pile-count ?kitchen [k food]) 0)))
      (when (poll (rest-cell ?kitchen [k pile]): ?cell))
      (effects (maintain-proposal {@self STOCK-LARDER ?kitchen ?cell})))
    (try
      (role @self {@self wander ?home /succ /caused_by ?p-rel}
        (effects (set-outcome ?p-rel /succ))))))
