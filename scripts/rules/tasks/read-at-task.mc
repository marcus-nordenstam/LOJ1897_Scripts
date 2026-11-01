; ----------------------------------------------------------------------------
; read-at ?home - an hour with a book in the study of his home, for a bored or a crowded man
; (drivers/household-driver.mc): a book off the shelf, the one he likes best the likeliest, read,
; then the rest of the hour sat there.
; ----------------------------------------------------------------------------

(task {@self read-at ?home}:?read-at
  (construed-act play-act)
  (tar [k structure|space] @object)
  (running-requirements (stands-in-room-of [k study] ?home))
  (sequence
    (stage
      (role ?book [k book] (= (spatial ?book space) (spatial ?home room [k study]))
                           (select (score (book-appeal (kind ?book))) (policy roulette)))
      (effects (maintain-proposal {@self read-doc ?book})))
    (stage
      (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)})))
    (stage
      (effects (set-outcome ?read-at /succ)))))
