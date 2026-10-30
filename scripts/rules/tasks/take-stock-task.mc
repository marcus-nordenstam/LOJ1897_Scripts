; ----------------------------------------------------------------------------
; take-stock ?shop - go to the shop and take stock at the counter (STOCKTAKE).
; ----------------------------------------------------------------------------

(task {@self take-stock ?shop}:?take-stock
  (construed-act toil-act)
  (tar [k shop] @object)
  (and
    (try
      (role @self (not (spatial @self building ?shop))
        (effects (maintain-proposal {@self enter-building ?shop}))))
    (try
      (role @self (spatial @self building ?shop)
        (effects (maintain-proposal {@self STOCKTAKE}))))
    (try
      (role @self {@self STOCKTAKE /succ /caused_by ?take-stock}
        (effects (set-outcome ?take-stock /succ))))))
