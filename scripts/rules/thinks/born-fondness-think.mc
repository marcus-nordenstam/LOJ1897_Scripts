; ----------------------------------------------------------------------------
; born-fondness - the arbitrary love a man holds from the start: once, when his mind first
; deliberates, by chance, a particular of any category (funcs/particulars.mc). It never moves.
; ----------------------------------------------------------------------------

(think born-fondness
  (cooldown 200 y try-once)
  (rng-stream behaviour)
  (belief {@self age ?}
    (when (latch-eval (chance (sensitivity-chance))))
    (effects
      (bind (draw-particular) ?loved)
      (begin-belief {@self fondness ?loved}))))
