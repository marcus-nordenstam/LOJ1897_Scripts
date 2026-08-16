; ----------------------------------------------------------------------------
; stack_bury - the dumb hands act of the top-of-stack iteration
; (take_my_letters_think.hs). Re-files the top ?doc at the BOTTOM (one
; attr-rotate step, then re-point the stack's top at the rotation's new last
; element) - a NEW doc surfaces as the top, and the observing NPC's mirrored
; {?stack top ..} belief follows through ordinary perception.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self STACK_BURY ?doc ?stack}
  (duration 1)
  (effects
    (attr-rotate ?stack items): ?newtop
    (set-attr ?stack top ?newtop)
    (set-outcome {@self STACK_BURY ?doc ?stack} succ)))
