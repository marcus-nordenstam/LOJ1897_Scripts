; ----------------------------------------------------------------------------
; emigration-driver - a fertile-age adult decides to leave the parish, a monthly chance scaled by
; the parish's crowding (population-pressure) and his own openness. At carrying capacity the
; base 0.00125 a month is about 1.5% a year. The roll is latched, so the emigrate task
; (tasks/emigrate-task.mc) holds until he is gone. A man who owns anything stays: he has
; no way yet to sell up.
; ----------------------------------------------------------------------------

(driver emigration-driver
  (cooldown 1 m try-once)
  (rng-stream migrations)
  (role @self {@self openness ?openness}
              {@self isa [k human], condition [k alive]}
              {@self age-band [k youth|young-adult|middle-aged]}
              -{@self own ?}
    (when (latch-eval (chance (* 0.00125 (+ 0.5 ?openness) (population-pressure)))))
    (declare-utility errand)
    (effects (maintain-proposal {@self emigrate}))))
