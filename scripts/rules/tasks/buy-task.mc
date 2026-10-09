; ----------------------------------------------------------------------------
; buy ?kind - the lawful purchase of an instance of ?kind. Shops are the item source
; (STOCKTAKE stocks them), so: walk to a shop, find a shelf item of the kind, count its
; price out of the carrying cash, pay it into the shop's till, and take the item. The
; shelf sweep is the burgle/means loot-walk shape (env-truth room + content sweep, first
; hit is the pick). Concludes on hand.
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
          (effects (maintain-proposal {@self go-to ?shop})))))
    ; knows no shop -> search the region for one, until the search proves there is none.
    (try
      (no-role [k shop])
      (when (and (empty (spatial @self hold ?kind))
                 -{@self find-building [k shop] ? /fail}
                 (current-exterior @self): ?rg))
      (declare-utility fallback)
      (effects (maintain-proposal {@self find-building [k shop] ?rg})))
    ; at a shop with a till -> the goods, the price counted into the hand, paid into the
    ; till, the goods taken. The goods are taken only once the price is in the till.
    (sequence
      (role ?cash {@self carrying-cash ?cash}
        (role ?till [k pile] {?till content-kind [k coin]}
                    (spatial ?till co-located @self)
                    (unknown (spatial ?till gripped-by))
          (when (and (empty (spatial @self hold ?kind))
                     (is-a (spatial @self building): ?shop [k shop])))

          (stage
            (effects
              (if (not (bb-any ?buy goods))
                  (then
                    (for-each ?room (spatial ?shop parts [k room] /env)
                      (for-each ?item (spatial ?room contents ?kind /env) [/limit 1]
                        (if (not (bb-any ?buy goods))
                            (then (bb-write ?buy goods ?item)))))))))

          (stage
            (when (bb-any ?buy goods))
            (bind (bb-read ?buy goods) ?goods)
            (effects
              (any {@self carrying-cash.count ?cash-count=0})
              (if (and -{@self /succ PILE-TRANSFER ? ?till /caused_by ?buy}
                       (not (bb-any ?buy coins))
                       (>= ?cash-count (price ?goods))
                       (empty (spatial (spatial @self right-hand) grip)))
                  (then (maintain-proposal {@self PILE-SPLIT ?cash (price ?goods)}:?PILE-SPLIT
                          [/postlude (bb-write ?buy coins (bb-read ?PILE-SPLIT created))])))))

          (stage
            (when (bb-any ?buy coins))
            (bind (bb-read ?buy coins) ?counted)
            (effects
              (if -{@self /succ PILE-TRANSFER ?counted ?till /caused_by ?buy}
                  (then (maintain-proposal {@self PILE-TRANSFER ?counted ?till})))))

          (stage
            (when {@self /succ PILE-TRANSFER ? ?till /caused_by ?buy})
            (bind (bb-read ?buy goods) ?goods)
            (effects
              (if (spatial ?goods co-located @self)
                  (then (maintain-proposal {@self GRASP ?goods (spatial @self right-hand)}))))))))
    ; concluded: an instance of the kind is in hand.
    (try
      (when (not (empty (spatial @self hold ?kind))))
      (effects (set-outcome ?buy /succ)))))
