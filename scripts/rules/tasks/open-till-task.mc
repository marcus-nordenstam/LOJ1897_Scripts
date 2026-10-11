; ----------------------------------------------------------------------------
; open-till ?shop - start the shop's till: an empty coin pile counted off the keeper's
; carrying-cash-pile and set down in the room he stands in. Buyers pay into it.
; ----------------------------------------------------------------------------

(task {@self open-till ?shop}:?open-till
  (tar [k shop] @object)
  (and
    (sequence
      (stage
        (effects
          (if (unsubstantial (coin-pile-in-hand @self))
              (then (maintain-proposal {@self unpocket-coins 0})))))

      (stage
        (bind (coin-pile-in-hand @self) ?till)
        (effects
          (if (substantial ?till)
              (then (maintain-proposal {@self put ?till (spatial @self space)}))))))
    (try
      (when {@self /succ put ? ? /caused_by ?open-till})
      (effects (set-outcome ?open-till /succ)))))
