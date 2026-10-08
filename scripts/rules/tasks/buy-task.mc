; ----------------------------------------------------------------------------
; buy ?kind - the lawful purchase of an instance of ?kind. Shops are the item source
; (STOCKTAKE stocks them), so: walk to a shop, then pay the proprietor and take a
; shelf item off in one atomic BUY act. The shelf sweep is the burgle/means loot-walk
; shape (env-truth room + content sweep, first hit is the pick). Concludes on hand.
; ----------------------------------------------------------------------------

(task {@self buy ?kind}:?buy
  (tar ?)
  (and
    ; not at a shop -> head to a shop @self KNOWS (any shop carries the stock).
    (try
      (role ?shop [k shop] (select (score (near @self ?shop)) (policy roulette unknown-last))
        (role @self (not (spatial @self building ?shop))
          (when (empty (spatial @self hold ?kind)))
          (declare-utility fallback)
          (effects (maintain-proposal {@self go ?shop})))))
    ; knows no shop -> search the region for one, until the search proves there is none.
    (try
      (no-role [k shop])
      (when (and (empty (spatial @self hold ?kind))
                 -{@self find-building [k shop] ? /fail}
                 (current-exterior @self): ?rg))
      (declare-utility fallback)
      (effects (maintain-proposal {@self find-building [k shop] ?rg})))
    ; at a shop -> find a shelf item of the kind and buy it (pay + take, atomic).
    (try
      (when (and (empty (spatial @self hold ?kind))
                 (is-a (spatial @self building): ?shop [k shop])))
      (effects
        (bind 0 ?found)
        (for-each ?room (spatial ?shop rooms /env)
          (for-each ?item (spatial ?room contents ?kind /env) [/limit 1]
            (if (= ?found 0) (then (bind ?item ?goods) (bind 1 ?found)))))
        (if (= ?found 1)
            (then
              (any {?shopkeeper own ?shop})
              (maintain-proposal {@self BUY ?goods ?shopkeeper})))))
    ; concluded: an instance of the kind is in hand.
    (try
      (when (not (empty (spatial @self hold ?kind))))
      (effects (set-outcome ?buy /succ)))))
