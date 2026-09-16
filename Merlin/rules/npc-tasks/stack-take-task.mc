; ----------------------------------------------------------------------------
; stack-take ?stack - lift ?stack's top paper into a free hand. The twin of `take` for a
; pile: the sanity try asserts a hand is free (a proposer lifting with full hands is an
; authoring error); the two hand tries propose the sided act (right-handed default:
; RIGHT-STACK-TAKE outbids LEFT-STACK-TAKE); the outcome try concludes once either hand's
; lift succeeded /caused_by this task.
;
; NO DOC IS NAMED, here or in the acts. A stack has no random access, so the paper that
; comes up is whatever was on top at the moment of the reach - not what the proposer
; believed was exposed when he looked. The caller finds what he lifted in his hand.
; ----------------------------------------------------------------------------

(npc-task {@self stack-take ?stack}:?stack-take-rel
  (tar @excl stack)
  (and
    (try
      (effects (check (or (empty (spatial (spatial @self left-hand) grip))
                          (empty (spatial (spatial @self right-hand) grip))))))
    (try
      (role @self (spatial ?stack co-located @self))
      (when (empty (spatial (spatial @self left-hand) grip)))
      (utility fallback)
      (effects (maintain-proposal {@self LEFT-STACK-TAKE ?stack})))
    (try
      (role @self (spatial ?stack co-located @self))
      (when (empty (spatial (spatial @self right-hand) grip)))
      (utility (above LEFT-STACK-TAKE))
      (effects (maintain-proposal {@self RIGHT-STACK-TAKE ?stack})))
    (try
      (when {@self /succ LEFT-STACK-TAKE|RIGHT-STACK-TAKE ?stack /caused_by ?stack-take-rel})
      (effects (set-outcome ?stack-take-rel /succ)))))
