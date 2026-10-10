; ----------------------------------------------------------------------------
; take-stock ?shop - go to the shop and take stock at the counter (STOCKTAKE).
; ----------------------------------------------------------------------------

(task {@self take-stock ?shop}:?take-stock
  (tar [k shop] @object)
  (and
    (try
      (role @self (not (spatial @self building ?shop))
        (effects (maintain-proposal {@self go-to ?shop}))))
    (try
      (role @self (spatial @self building ?shop)
        (effects (maintain-proposal {@self STOCKTAKE}))))
    (try
      (when {@self STOCKTAKE /succ /caused_by ?take-stock})
      (effects (set-outcome ?take-stock /succ)))))
