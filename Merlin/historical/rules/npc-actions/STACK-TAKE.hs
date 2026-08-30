; ----------------------------------------------------------------------------
; stack_take - the dumb hands act of stack iteration (stack_browse_think.hs).
; Pops ?stack's top into @self's hand. ?doc names the doc the proposing think
; believed exposed - the pop itself takes whatever the top IS (stacks have no
; random access).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self STACK_TAKE ?doc ?stack}
  (duration 1)
  (effects
    (pop ?stack)
    (set-outcome {@self STACK_TAKE ?doc ?stack} /succ)))
