

(action {@self OFFER-LEFT ?thing ?recipient}:?OFFER-LEFT
  (motor body legs)
  (tar [k object] @object) (aux [k human] @object) (duration 0)
  (effects
    (spatial ?recipient left-hand /env): ?recipient-hand
    (do
      (check (= (spatial ?thing held-by) @self))
      (check (spatial @self can-reach ?recipient /env))
      (check (empty (spatial ?recipient-hand grip /env)))
      (spatial-write ?thing gripped-by ?recipient-hand /env)
      (set-outcome ?OFFER-LEFT /succ))))

(action {@self OFFER-RIGHT ?thing ?recipient}:?OFFER-RIGHT
  (motor body legs)
  (tar [k object] @object) (aux [k human] @object) (duration 0)
  (effects
    (spatial ?recipient right-hand /env): ?recipient-hand
    (do
      (check (= (spatial ?thing held-by) @self))
      (check (spatial @self can-reach ?recipient /env))
      (check (empty (spatial ?recipient-hand grip /env)))
      (spatial-write ?thing gripped-by ?recipient-hand /env)
      (set-outcome ?OFFER-RIGHT /succ))))
