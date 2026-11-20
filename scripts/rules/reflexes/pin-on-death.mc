; ----------------------------------------------------------------------------
; pin-on-death - learning that a man is dead, by seeing the body or by being told, makes him and
; the days before it matter: every episode held about him, and every episode of the last week,
; stays the dated event it was - no sleep folds it into a habit. Kept apart from obligation-burial
; on the same gate: that one is a priest's duty, this one is memory.
; ----------------------------------------------------------------------------

(reflex {?corpse condition [k dead]}
  (effects
    (pin-episodes-about ?corpse)
    (pin-episodes-during (- (time seconds) (seconds (k-death-pin-seconds) s)) (time seconds))))
