; ----------------------------------------------------------------------------
; buy ?kind - the lawful purchase of an instance of ?kind. Shops are the item source
; (STOCKTAKE stocks them), so: walk to a shop, then pay the proprietor and take a
; shelf item off in one atomic BUY act. The shelf sweep is the burgle/means loot-walk
; shape (env-truth room + content sweep, first hit is the pick). Concludes on hand.
; ----------------------------------------------------------------------------

(npc-task {@self buy ?kind}:?buy-rel
  (tar ?)
  (and
    ; not at a shop -> head to one (any shop carries the stock).
    (try
      (when (and (empty (spatial @self hold ?kind))
                 (find-building [k building shop]): ?shop
                 (not (spatial @self building ?shop))))
      (utility fallback)
      (effects (maintain-proposal {@self enter ?shop})))
    ; at a shop -> find a shelf item of the kind and buy it (pay + take, atomic).
    (try
      (when (and (empty (spatial @self hold ?kind))
                 (is-a (spatial @self building) [k building shop])))
      (effects
        (spatial @self building): ?shop
        (bind 0 ?found)
        (for-each ?room (spatial ?shop parts [k interior_space room] /env)
          (for-each ?item (spatial ?room contents ?kind /env) /limit 1
            (if (= ?found 0) (then (bind ?item ?goods) (bind 1 ?found)))))
        (if (= ?found 1)
            (then (maintain-proposal {@self BUY ?goods (owner-of ?shop)})))))
    ; concluded: an instance of the kind is in hand.
    (try
      (when (not (empty (spatial @self hold ?kind))))
      (effects (set-outcome ?buy-rel /succ)))))
