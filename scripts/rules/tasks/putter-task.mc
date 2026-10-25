; ----------------------------------------------------------------------------
; putter - the monthly home round: one `wander` of home, which walks every known room - and
; a hidden cache in one is noticed, now and then, by perception itself (the sensor's
; notices_hidden_space), as anyone's eye may catch it. Mail is `read-mail` on its own cadence.
;
;   wander : MAINTAIN one wander of home until it succeeds - an interrupted putter withdraws
;            it, a resumed putter mints it fresh.
;   done   : the wander concluded -> end.
; ----------------------------------------------------------------------------

(task {@self putter ?home}:?putter
  (tar [k unit] @object)
  (and
    (try
      (role @self -{@self wander ?home /succ /caused_by ?putter}
        (effects (maintain-proposal {@self wander ?home}))))
    ; STOPGAP (actions/STOCK-LARDER.mc): the supply run never reaches the shop, so a
    ; resident standing in his own empty kitchen stocks it himself. Delete with that file.
    (try
      (when (and (spatial @self unit ?home)
                 (spatial ?home room [k kitchen]): ?kitchen
                 (spatial @self space ?kitchen)
                 (= (believed-pile-count ?kitchen [k food]) 0)))
      (when (poll (rest-spot ?kitchen [k pile]): ?spot))
      (effects (maintain-proposal {@self STOCK-LARDER ?kitchen ?spot})))
    (try
      (role @self {@self wander ?home /succ /caused_by ?putter}
        (effects (set-outcome ?putter /succ))))))
