; ----------------------------------------------------------------------------
; accept-lover - told by someone that they are now @self's lover (take-lover), @self takes them
; as a lover in turn when attracted to them, or when the stray in their own character carries
; them along. A lover bond is built on attraction, so it grounds @self's own pull towards them.
; ----------------------------------------------------------------------------

(include "../../../macros/affair-macros.mc")

(think accept-lover
  (rng-stream marriages)
  (role @self {@self age-band [k young-adult|middle-aged|mature|elderly]}
    (role ?suitor {?suitor isa [k human], condition [k alive]}
                  {?suitor lover @self}
                  -{@self lover ?suitor}
      (when (latch-eval (chance (max (prob {@self fancy|desire|crave ?suitor})
                                     (any {@self infidelity-disposition ?=0.0}).target))))
      (effects
        (begin-belief {@self lover ?suitor})
        (nudge-stance ?suitor attraction (lover_attraction_floor))))))
