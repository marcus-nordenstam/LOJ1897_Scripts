; ----------------------------------------------------------------------------
; common-ground (reflex) - learning that a man shares an interest of @self's warms @self to him,
; the shared interest the cause of the stance it moves.
; ----------------------------------------------------------------------------

(reflex {?other interest ?domain /ever}:?interest
  (when (and (dirty-born) (neq ?other @self) {@self interest ?domain}))
  (effects (nudge-stance ?other warmth (shared-interest-warmth) ?interest)))
