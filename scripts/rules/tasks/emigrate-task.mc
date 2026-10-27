; ----------------------------------------------------------------------------
; emigrate - give up his post (retire), then leave the world (DEPART).
; ----------------------------------------------------------------------------

(task {@self emigrate}:?emigrate
  (preemptive-or
    (try
      (role @self {@self DEPART /succ /caused_by ?emigrate}
        (effects (set-outcome ?emigrate /succ))))
    (try
      (role @self {@self job ?}
        (effects (maintain-proposal {@self retire}))))
    (try
      (effects (maintain-proposal {@self DEPART})))))
