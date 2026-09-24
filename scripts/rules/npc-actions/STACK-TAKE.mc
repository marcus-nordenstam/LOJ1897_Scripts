; ----------------------------------------------------------------------------
; STACK-TAKE ?stack ?hand - lift whatever is on top of ?stack into ?hand. ONE act for
; both hands and both LODs; it absorbs LEFT-STACK-TAKE / RIGHT-STACK-TAKE and the isim
; STACK_TAKE handler, whose whole env half was commented out behind the spatial-index
; rewrite this discharges.
;
; A STACK HAS NO RANDOM ACCESS: the pop takes whatever is on top, which is why no doc
; is named here or in the task. What came up is recorded ON THE PAPER - (bb-read ?doc
; from-stack) is the pile it owes a return to - and STACK-PUT / STACK-BURY discharge
; that note when it is filed again. So a man always knows which paper in his hands came
; off which pile, whatever else he is carrying, and no task has to remember it for him.
; ----------------------------------------------------------------------------


(npc-action {@self STACK-TAKE ?stack ?hand}:?take
  (sided aux left-hand right-hand)
  (obs)
  (tar @excl)
  (duration (seconds 1 min))
  (presentation
    (preroll 0.0) (in 0.3) (out 0.3))

  (effects
    (check (spatial ?stack co-located @self /env))
    (check (empty (spatial ?hand grip /env)))
    (pop ?stack ?hand): ?taken
    (cond
      (case (substantial ?taken)
        (observe ?taken): ?known
        (bb-write ?known from-stack ?stack)
        ; The pile has a new face, and a man who lifts the top paper sees what lay under
        ; it. Nothing else re-looks - a mind learns a pile's top by observing it and by
        ; no other route - so without this every reader of (spatial ?stack top) steers by
        ; the pile as it stood before his own hand moved it, and a walk that lifts one
        ; doc at a time can never reach the second.
        (tolerate (observe (spatial ?stack top /env)))
        (if (presented-lod)
            (then (attach-to-socket ?taken @self (side ?hand))))
        (set-outcome ?take /succ))
      (else (set-outcome ?take /fail)))))
