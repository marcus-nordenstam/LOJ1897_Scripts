; ----------------------------------------------------------------------------
; give ?thing ?recipient - hand a held thing to a co-present person. Decomposes into
; general primitives: take (if unheld) -> go (if the recipient is elsewhere, seeking
; their home when their whereabouts are unknown) -> the sided OFFER that re-edges the
; grip into the recipient's free hand. The ended {@self give ?thing ?recipient} belief
; IS the give memory (act/state doctrine). Conclusive outcome: the grip landed on the
; recipient. Abandon: no live recipient to give to.
; ----------------------------------------------------------------------------

(npc-task {@self give ?thing ?recipient}:?give-rel
  (tar @excl object)
  (aux human)
  (and
    (try
      (when (!= (spatial ?thing held-by) @self))
      (utility fallback)
      (effects (maintain-proposal {@self take ?thing})))
    (try
      (when (and (= (spatial ?thing held-by) @self)
                 (not (spatial ?recipient co-located @self))
                 (spatial ?recipient space): ?loc))
      (utility fallback)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (= (spatial ?thing held-by) @self)
                 (not (spatial ?recipient co-located @self))
                 (unknown (spatial ?recipient space))
                 {?recipient home ?rhome}))
      (effects (maintain-proposal {@self go ?rhome})))
    (try
      (when (and (= (spatial ?thing held-by) @self)
                 (spatial ?recipient co-located @self)
                 (empty (spatial (spatial ?recipient right-hand) grip))))
      (utility (above go))
      (effects (maintain-proposal {@self OFFER-RIGHT ?thing ?recipient})))
    (try
      (when (and (= (spatial ?thing held-by) @self)
                 (spatial ?recipient co-located @self)
                 (not (empty (spatial (spatial ?recipient right-hand) grip)))))
      (utility (above go))
      (effects (maintain-proposal {@self OFFER-LEFT ?thing ?recipient})))
    (try
      (when {@self /succ OFFER-LEFT|OFFER-RIGHT ?thing ?recipient /caused_by ?give-rel})
      (effects (set-outcome ?give-rel /succ)))
    (try
      (when (not (alive ?recipient)))
      (effects (set-outcome ?give-rel /fail)))))
