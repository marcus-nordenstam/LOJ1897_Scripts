; ----------------------------------------------------------------------------
; emigrate - give up his post (retire), then leave the world (DEPART).
; ----------------------------------------------------------------------------

(task {@self emigrate}:?emigrate
  (preemptive-or
    (try
      (belief {@self DEPART /succ /caused_by ?emigrate}
        (effects (set-outcome ?emigrate /succ))))
    (try
      (belief {@self job ?}
        (effects (maintain-proposal {@self retire}))))
    (try
      (effects (maintain-proposal {@self DEPART})))))
