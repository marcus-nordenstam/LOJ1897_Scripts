; ----------------------------------------------------------------------------
; stack_take - the dumb hands act of stack iteration. Pops ?stack's top into @self's hand.
; ?doc names the doc the proposing think believed exposed; the pop takes whatever the top
; IS (stacks have no random access), so the two differ whenever the belief has gone stale.
; The doc actually lifted rides the act under `taken` - that, not ?doc, is what the caller
; must go on.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-action {@self STACK-TAKE ?doc ?stack}:?take-rel
  (duration 1)
  (effects
    (check (spatial ?stack co-located @self /env))
    (spatial @self right-hand /env): ?rh
    (if (empty (spatial ?rh grip /env))
        (then (pop ?stack ?rh))
        (else (pop ?stack (spatial @self left-hand /env)))): ?taken
    (if (substantial ?taken)
        (then (observe ?taken): ?known
              (bb-write ?take-rel taken ?known)
              ; The pile has a new face, and a man who lifts the top paper sees what lay
              ; under it. Nothing else re-looks - a mind learns a pile's top by observing it
              ; and by no other route - so without this every reader of (spatial ?stack top)
              ; steers by the pile as it stood before his own hand moved it, and a walk that
              ; lifts one doc at a time can never reach the second.
              (tolerate (observe (spatial ?stack top /env)))
              (set-outcome ?take-rel /succ))
        (else (set-outcome ?take-rel /fail)))))
