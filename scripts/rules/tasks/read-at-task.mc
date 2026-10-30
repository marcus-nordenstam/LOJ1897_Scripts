; ----------------------------------------------------------------------------
; read-at ?home - an hour with a book in the study of his home, for a bored or a crowded man
; (drivers/household-driver.mc).
; ----------------------------------------------------------------------------

(task {@self read-at ?home}:?read-at
  (construed-act play-act)
  (tar [k structure|space] @object)
  (running-requirements (stands-in-room-of [k study] ?home))
  (sequence
    (stage
      (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)})))
    (stage
      (effects (set-outcome ?read-at /succ)))))
