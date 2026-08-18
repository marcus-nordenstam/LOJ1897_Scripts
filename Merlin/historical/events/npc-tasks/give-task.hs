; ----------------------------------------------------------------------------
; give ?thing ?recipient - hand a held thing to a co-present person. Decomposes into
; general primitives: take (if unheld) -> go (if the recipient is elsewhere, seeking
; their home when their whereabouts are unknown) -> the sided OFFER that re-edges the
; grip into the recipient's free hand. The ended {@self give ?thing ?recipient} belief
; IS the give memory (act/state doctrine). Conclusive outcome: the grip landed on the
; recipient. Abandon: no live recipient to give to.
; ----------------------------------------------------------------------------

(npc-task {@self give ?thing ?recipient}:?give
  (tar @excl object)
  (aux human)
  (and
    (try
      (when (not (= (spatial ?thing held_by) @self)))
      (utility fallback)
      (effects (maintain-proposal {@self take ?thing})))
    (try
      (when (and (= (spatial ?thing held_by) @self)
                 (not (co-present ?recipient @self))
                 (location ?recipient): ?loc))
      (utility fallback)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (= (spatial ?thing held_by) @self)
                 (not (co-present ?recipient @self))
                 (unknown (location ?recipient))))
      (effects (maintain-proposal {@self go (home-of ?recipient)})))
    (try
      (when (and (= (spatial ?thing held_by) @self)
                 (co-present ?recipient @self)
                 (empty (spatial (spatial ?recipient right_hand) grip))))
      (utility (above go))
      (effects (maintain-proposal {@self OFFER_RIGHT ?thing ?recipient})))
    (try
      (when (and (= (spatial ?thing held_by) @self)
                 (co-present ?recipient @self)
                 (not (empty (spatial (spatial ?recipient right_hand) grip)))))
      (utility (above go))
      (effects (maintain-proposal {@self OFFER_LEFT ?thing ?recipient})))
    (try
      (when (any {@self /succ OFFER_LEFT|OFFER_RIGHT ?thing ?recipient /caused_by ?give}))
      (effects (set-outcome ?give succ)))
    (try
      (when (not (alive ?recipient)))
      (effects (set-outcome ?give fail)))))
