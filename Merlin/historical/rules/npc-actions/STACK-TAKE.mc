; ----------------------------------------------------------------------------
; stack_take - the dumb hands act of stack iteration (stack_browse_think.hs).
; Pops ?stack's top into @self's hand. ?doc names the doc the proposing think
; believed exposed - the pop itself takes whatever the top IS (stacks have no
; random access).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self STACK-TAKE ?doc ?stack}
  (duration 1)
  (effects
    (if (empty (spatial (spatial @self right-hand) grip))
        (then (pop ?stack (spatial @self right-hand)))
        (else (pop ?stack (spatial @self left-hand)))): ?taken
    (if (substantial ?taken)
        (then (observe ?taken)
              (set-outcome {@self STACK-TAKE ?doc ?stack} /succ))
        (else (set-outcome {@self STACK-TAKE ?doc ?stack} /fail)))))
