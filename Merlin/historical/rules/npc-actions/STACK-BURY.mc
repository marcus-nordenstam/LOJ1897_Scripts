; ----------------------------------------------------------------------------
; stack_bury - the dumb hands act of stack iteration (stack_browse_think.hs).
; Files the held ?doc at ?stack's BOTTOM (the grip releases as part of the
; bury), beneath every other filing.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self STACK-BURY ?doc ?stack}
  (duration 1)
  (effects
    (bury ?doc ?stack)
    (set-outcome {@self STACK-BURY ?doc ?stack} /succ)))
