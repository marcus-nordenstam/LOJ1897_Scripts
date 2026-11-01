; ----------------------------------------------------------------------------
; born-aversion - the arbitrary hate a man holds from the start: once, when his mind first
; deliberates, by chance, a particular of any category (funcs/particulars.mc). It never moves.
; ----------------------------------------------------------------------------

(think born-aversion
  (cooldown 200 y try-once)
  (rng-stream behaviour)
  (role @self {@self age ?}
    (when (latch-eval (chance (sensitivity-chance))))
    (effects
      (bind (draw-particular) ?hated)
      (begin-belief {@self aversion ?hated}))))
