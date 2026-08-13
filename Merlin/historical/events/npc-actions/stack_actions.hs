; ----------------------------------------------------------------------------
; stack_take / stack_bury - the dumb hands acts of the top-of-stack iteration
; (take_my_letters_think.hs). stack_take lifts ?doc OUT of ?stack into @self's
; hand; stack_bury re-files the top ?doc at the BOTTOM (one attr-rotate step,
; then re-point the stack's top at the rotation's new last element) - either way
; a NEW doc surfaces as the top, and the observing NPC's mirrored {?stack top ..}
; belief follows through ordinary perception.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self stack_take ?doc ?stack}
  (duration 1)
  (effects
    (take-from-stack ?doc)
    (set-outcome {@self stack_take ?doc ?stack} succ)))

(npc-action {@self stack_bury ?doc ?stack}
  (duration 1)
  (effects
    (attr-rotate ?stack items): ?newtop
    (set-attr ?stack top ?newtop)
    (set-outcome {@self stack_bury ?doc ?stack} succ)))
