; ----------------------------------------------------------------------------
; pay ?payee ?count - give ?payee ?count coins: the coin pile @self holds, else ?count coins
; counted out of the carrying-cash-pile (unpocket-coins). Witnessed (obs): a payee who sees it
; paid holds it, which is what lapses a threat that demanded it.
; ----------------------------------------------------------------------------

(task {@self pay ?payee ?count}:?pay
  (tar [k human] @object)
  (aux ?)
  (obs)
  (failure-cond (not (alive ?payee)))
  (and
    (try
      (role ?counted [k pile] {?counted content-kind [k coin]} (= (spatial ?counted held-by) @self)
                     (select (policy first-match))
        (when (alive ?payee))
        (effects (maintain-proposal {@self give ?counted ?payee}))))
    (try
      (role -?coins [k pile] {?coins content-kind [k coin]} (= (spatial ?coins held-by) @self))
      (when (alive ?payee))
      (effects (maintain-proposal {@self unpocket-coins ?count})))
    (try
      (belief {@self give ? ?payee /succ /caused_by ?pay}
        (effects (set-outcome ?pay /succ))))))
