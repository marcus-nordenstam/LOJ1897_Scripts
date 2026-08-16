; ----------------------------------------------------------------------------
; stack_take - the dumb hands act of the top-of-stack iteration
; (take_my_letters_think.hs). Lifts ?doc OUT of ?stack into @self's hand - a
; NEW doc surfaces as the top, and the observing NPC's mirrored {?stack top ..}
; belief follows through ordinary perception.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self STACK_TAKE ?doc ?stack}
  (duration 1)
  (effects
    (take-from-stack ?doc)
    (set-outcome {@self STACK_TAKE ?doc ?stack} succ)))
