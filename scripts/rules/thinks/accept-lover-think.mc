; ----------------------------------------------------------------------------
; accept-lover - told by someone that they are now @self's lover (take-lover), @self takes them
; as a lover in turn when attracted to them, or when the stray in their own character carries
; them along. A lover bond is built on attraction, so it grounds @self's own pull towards them.
; ----------------------------------------------------------------------------

(include "../../macros/affair-macros.mc")

; How readily @self takes ?suitor as a lover: the pull towards them (none when he holds no
; belief of one), or the stray in their own character, whichever is the greater.
(define-func lover-acceptance (?suitor)
  (any {@self infidelity-disposition ?infidelity-disposition=0.0})
  (prob {@self fancy|desire|crave ?suitor}): ?pull
  (max (if (substantial ?pull) (then ?pull) (else 0.0)) ?infidelity-disposition))

(think accept-lover
  (rng-stream marriages)
  (role @self {@self age-band [k young-adult|middle-aged|mature|elderly]}
    (role ?suitor {?suitor isa [k human], condition [k alive]}
                  {?suitor lover @self}
                  -{@self lover ?suitor}
      (when (latch-eval (chance (lover-acceptance ?suitor))))
      (effects
        (begin-belief {@self lover ?suitor})
        (nudge-stance ?suitor attraction (lover_attraction_floor))))))
