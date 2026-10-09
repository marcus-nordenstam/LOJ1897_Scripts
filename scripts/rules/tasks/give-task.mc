; ----------------------------------------------------------------------------
; give ?thing ?recipient - hand a held thing to a co-present person. Decomposes into
; general primitives: take (if unheld) -> go (if the recipient is elsewhere, seeking
; their home when their whereabouts are unknown) -> the sided OFFER that re-edges the
; grip into the recipient's free hand. The ended {@self give ?thing ?recipient} belief
; IS the give memory (act/state doctrine). Conclusive outcome: the grip landed on the
; recipient. Abandon: no live recipient to give to.
; ----------------------------------------------------------------------------

(task {@self give ?thing ?recipient}:?give
  (tar @excl [k object] @object)
  (aux [k human] @object)
  (and
    (try
      (when (!= (spatial ?thing held-by) @self))
      (declare-utility fallback)
      (effects (maintain-proposal {@self take ?thing})))
    (try
      (when (and (= (spatial ?thing held-by) @self)
                 (not (spatial ?recipient co-located @self))
                 (spatial ?recipient space)))
      (declare-utility fallback)
      (effects (maintain-proposal {@self go-to ?recipient})))
    (try
      (role ?rhome {?recipient home ?rhome}
        (when (and (= (spatial ?thing held-by) @self)
                   (not (spatial ?recipient co-located @self))
                   (unknown (spatial ?recipient space))))
        (effects (maintain-proposal {@self go-to ?rhome}))))
    (try
      (when (and (= (spatial ?thing held-by) @self)
                 (spatial ?recipient co-located @self)
                 (empty (spatial (spatial ?recipient right-hand) grip))))
      (declare-utility (above go-to))
      (effects (maintain-proposal {@self OFFER-RIGHT ?thing ?recipient})))
    (try
      (when (and (= (spatial ?thing held-by) @self)
                 (spatial ?recipient co-located @self)
                 (not (empty (spatial (spatial ?recipient right-hand) grip)))))
      (declare-utility (above go-to))
      (effects (maintain-proposal {@self OFFER-LEFT ?thing ?recipient})))
    (try
      (when {@self /succ OFFER-LEFT|OFFER-RIGHT ?thing ?recipient /caused_by ?give})
      (effects (set-outcome ?give /succ)))
    (try
      (when (not (alive ?recipient)))
      (effects (set-outcome ?give /fail)))))
