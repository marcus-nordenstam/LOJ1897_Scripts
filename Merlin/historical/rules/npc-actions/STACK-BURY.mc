; ----------------------------------------------------------------------------
; stack_bury - the dumb hands act of stack iteration (stack_browse_think.hs).
; Files the held ?doc at ?stack's BOTTOM (the grip releases as part of the
; bury), beneath every other filing.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self STACK-BURY ?doc ?stack}
  (duration 1)
  (effects
    ; The twin of STACK-TAKE's: a man files a paper in the pile he is standing at.
    (check (spatial ?stack co-located @self /env))
    (bury ?doc ?stack)
    ; He is still standing at the pile he just filed into - the twin of STACK-TAKE's re-look.
    (tolerate (observe (spatial ?stack top /env)))
    (set-outcome {@self STACK-BURY ?doc ?stack} /succ)))
