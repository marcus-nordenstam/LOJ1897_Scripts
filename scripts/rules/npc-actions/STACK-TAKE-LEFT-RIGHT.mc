(include "../../definitions/roles.mc")

; A stack has no random access: the pop takes whatever is on top, which is why no doc is
; named here. What came up is recorded ON THE PAPER - (bb-read ?doc from-stack) is the pile
; it owes a return to - and STACK-PUT / STACK-BURY discharge that note when it is filed
; again. So a man always knows which paper in his hands came off which pile, whatever else
; he is carrying, and no task has to remember it for him.
(define-macro stack-take-effects (?hand ?stack ?take-action)
  (do
    ; these will fire in non-shipping builds, indicating badly designed rules that propose this action
    (check (spatial ?stack co-located @self /env))
    (check (empty (spatial ?hand grip /env)))
    (pop ?stack ?hand): ?taken
    (if (substantial ?taken)
        (then (observe ?taken): ?known
              (bb-write ?known from-stack ?stack)
              ; The pile has a new face, and a man who lifts the top paper sees what lay
              ; under it. Nothing else re-looks - a mind learns a pile's top by observing it
              ; and by no other route - so without this every reader of (spatial ?stack top)
              ; steers by the pile as it stood before his own hand moved it, and a walk that
              ; lifts one doc at a time can never reach the second.
              (tolerate (observe (spatial ?stack top /env)))
              (set-outcome ?take-action /succ))
        (else (set-outcome ?take-action /fail)))))

(npc-action {@self LEFT-STACK-TAKE ?stack}:?take-action-rel
  (duration 1)
  (effects
    (spatial @self left-hand /env): ?hand
    (stack-take-effects ?hand ?stack ?take-action-rel)))

(npc-action {@self RIGHT-STACK-TAKE ?stack}:?take-action-rel
  (duration 1)
  (effects
    (spatial @self right-hand /env): ?hand
    (stack-take-effects ?hand ?stack ?take-action-rel)))
