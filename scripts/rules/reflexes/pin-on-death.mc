; ----------------------------------------------------------------------------
; pin-on-death - learning that a man is dead, by seeing the body or by being told, makes him and
; the time of his death matter: every episode held about him, and every episode of the day either
; side of his death, stays the dated event it was - no sleep folds it into a habit. A death told
; with no time pins only what is held about him. Kept apart from obligation-burial on the same
; gate: that one is a priest's duty, this one is memory.
; ----------------------------------------------------------------------------

(reflex {?corpse condition [k dead]}:?dead
  (effects
    (pin-episodes-about ?corpse)
    (bind (start-time ?dead) ?died)
    (if (substantial ?died)
        (then (pin-episodes-during (- ?died (seconds 1 d)) (+ ?died (seconds 1 d)))))))
