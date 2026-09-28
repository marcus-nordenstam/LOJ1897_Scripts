

(npc-action {@self OFFER-LEFT ?thing ?recipient}:?offer-action-rel
  (motor body legs)
  (tar [k object] @object) (aux [k human] @object) (duration 0)
  (effects
    (spatial ?recipient left-hand /env): ?recipient-hand
    (do
      (check (= (spatial ?thing held-by) @self))
      (check (spatial @self co-located ?recipient))
      (check (empty (spatial ?recipient-hand grip /env)))
      (spatial-write ?thing gripped-by ?recipient-hand /env)
      (set-outcome ?offer-action-rel /succ))))

(npc-action {@self OFFER-RIGHT ?thing ?recipient}:?offer-action-rel
  (motor body legs)
  (tar [k object] @object) (aux [k human] @object) (duration 0)
  (effects
    (spatial ?recipient right-hand /env): ?recipient-hand
    (do
      (check (= (spatial ?thing held-by) @self))
      (check (spatial @self co-located ?recipient))
      (check (empty (spatial ?recipient-hand grip /env)))
      (spatial-write ?thing gripped-by ?recipient-hand /env)
      (set-outcome ?offer-action-rel /succ))))
