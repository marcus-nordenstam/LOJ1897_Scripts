; ----------------------------------------------------------------------------
; stack_put ?doc ?stack - the one dumb hands act of filing a doc onto ?stack's
; top. The twin of stack_take. Filing a doc INTO a pile is env mutation, so only
; an ACTION may do it. THE general "put in a stack": posting mail into an outgoing
; pile, lodging a listing / deed into a registry stack, shelving any document.
; ----------------------------------------------------------------------------

(npc-action {@self STACK-PUT ?doc ?stack}
  (duration 1)
  (effects
    (check (spatial ?stack co-located @self /env))
    (push ?doc ?stack)
    (observe ?doc)
    (set-outcome {@self STACK-PUT ?doc ?stack} /succ)))
