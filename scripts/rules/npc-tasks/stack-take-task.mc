; ----------------------------------------------------------------------------
; stack-take ?stack - lift ?stack's top paper into a free hand. The twin of `take` for a
; pile: the sanity try asserts a hand is free (a proposer lifting with full hands is an
; authoring error); the two hand tries propose STACK-TAKE with the hand as an ARGUMENT;
; the outcome try concludes once a lift succeeded /caused_by this task.
;
; The hand preference is a CONDITION for the same reason it is in `take`: one act, so
; nothing to outbid, and "the right hand unless it is busy" is what the rule actually
; says. The two rungs are then exclusive by construction.
;
; NO DOC IS NAMED, here or in the act. A stack has no random access, so the paper that
; comes up is whatever was on top at the moment of the reach - not what the proposer
; believed was exposed when he looked. The caller finds what he lifted in his hand.
; ----------------------------------------------------------------------------

(npc-task {@self stack-take ?stack}:?stack-take-rel
  (tar @excl stack)
  ; THE CONDITION THE TASK RUNS UNDER: nothing off this pile is in hand yet. Its own,
  ; not any proposer's - the moment the lift lands this stops holding and the task
  ; stops firing, whoever was asking for it.
  (when -{@self /succ STACK-TAKE ?stack ? /caused_by ?stack-take-rel})
  ; ...and the same test says which ending it was. A lift that landed is /succ; called
  ; off with empty hands, the cease says nothing and the withdrawal's /interrupted
  ; stands. A BARE PATTERN would not do here - evaluated in a payload it yields the
  ; clause itself, which is substantial, so it would always read true.
  (cease (if (any {@self /succ STACK-TAKE ?stack ? /caused_by ?stack-take-rel})
             (then (set-outcome ?stack-take-rel /succ))))
  (and
    (try
      (effects (check (or (empty (spatial (spatial @self left-hand) grip))
                          (empty (spatial (spatial @self right-hand) grip))))))
    (try
      (match (spatial ?stack co-located @self))
      (when (empty (spatial (spatial @self right-hand) grip)))
      (effects (maintain-proposal {@self STACK-TAKE ?stack (spatial @self right-hand)})))
    (try
      (match (spatial ?stack co-located @self))
      (when (empty (spatial (spatial @self left-hand) grip)))
      (when (not (empty (spatial (spatial @self right-hand) grip))))
      (effects (maintain-proposal {@self STACK-TAKE ?stack (spatial @self left-hand)})))))
