; ----------------------------------------------------------------------------
; PUT-ON - @self puts ?article on, on his ?part (a body-part kind: the part its apparel kind is worn
; on, or the one the proposer picks - a wedding band on the left ring finger).
;
; It becomes one of the things he wears, its `worn-on` that part, and he holds it from here, as a
; stowed thing is held: it rides him and is seen with him. The proposer decides which part; the act
; does no reasoning.
; ----------------------------------------------------------------------------

(action {@self PUT-ON ?article ?part}:?PUT-ON
  (motor right-hand)
  (duration 0.6)
  (presentation
    (preroll 0.0) (in 0.4) (out 0.4))

  (effects
    (check (spatial @self can-reach ?article /env))
    (set-attr ?article worn-on ?part)
    (add-attr-item-unique @self wear ?article)
    (grip-into-hand ?article @self)
    (if (presented-lod)
        (then (attach-to-socket ?article @self @nothing)))
    (set-outcome ?PUT-ON /succ)))
