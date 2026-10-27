; ----------------------------------------------------------------------------
; provision ?shop - go to the shop he knows sells provisions and buy a basket there
; (PROVISION). The basket's size is decided here (the larder's shortfall, what is already in
; hand, what he can carry) and rides the act: the counter-stop does no counting.
; ----------------------------------------------------------------------------

(task {@self provision ?shop}:?provision
  (tar [k shop] @object)
  (role ?home {@self household-cook ?home}
              (spatial ?home room [k kitchen]): ?kitchen
    (and
      (try
        (role @self (not (spatial @self building ?shop))
          (when (> (provision-basket ?kitchen) 0))
          (effects (maintain-proposal {@self go-to ?shop}))))
      (try
        (role @self (spatial @self building ?shop)
          (when (and (provision-basket ?kitchen): ?cap
                     (> ?cap 0)))
          (effects (maintain-proposal {@self PROVISION ?cap}))))
      (try
        (role @self {@self PROVISION ? /succ /caused_by ?provision}
          (effects (set-outcome ?provision /succ)))))))
