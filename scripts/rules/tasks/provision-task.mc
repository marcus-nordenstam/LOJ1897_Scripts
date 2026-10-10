; ----------------------------------------------------------------------------
; provision ?shop - go to the shop he knows sells provisions and buy a basket there
; (PROVISION). The basket's size is decided here (the larder's shortfall, what is already in
; hand, what he can carry) and rides the act: the counter-stop does no counting.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(task {@self provision ?shop}:?provision
  (tar [k shop] @object)
  (and
    (try
      (role @self (not (spatial @self building ?shop))
        (effects (maintain-proposal {@self go-to ?shop}))))
    (try
      (role @self (spatial @self building ?shop)
        (role ?home {@self household-cook ?home}
                    (spatial ?home room [k kitchen]): ?kitchen
          (when (and (believed-pile-count ?kitchen [k food]): ?blv
                     (held-pile-count @self [k food]): ?inh
                     (- (min (carry_cap) (- (larder_target) ?blv)) ?inh): ?cap
                     (> ?cap 0)))
          (effects (maintain-proposal {@self PROVISION ?cap})))))
    (try
      (when {@self PROVISION ? /succ /caused_by ?provision})
      (effects (set-outcome ?provision /succ)))))
