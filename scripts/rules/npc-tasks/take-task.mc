; ----------------------------------------------------------------------------
; take ?item - pick the item up into a free hand. The sanity try asserts a hand is free
; (a proposer taking with full hands is an authoring error); the two hand tries propose
; GRASP with the hand as an ARGUMENT; the outcome try concludes once a grasp succeeded
; /caused_by this task.
;
; THE HAND PREFERENCE IS A CONDITION, not a bid. It was (utility (above LEFT-TAKE)) -
; one act outbidding another - and there is ONE act now, so there is nothing to outbid.
; Said as a condition it is also the truth: the right hand, or the left when the right
; is busy. That makes the two rungs exclusive by construction, so neither can hold
; against the other and re-fight the auction every cycle.
;
; THE REACH IS A SELF-ROLE, not a check in the effects. GRASP asserts co-location, and
; an act's check ABORTS the run rather than deferring it - so the rung must HOLD until
; the item is at hand. It rides a (role @self ..) rather than a (when ..) because a
; (spatial ..) read is role-cacheable: on the role it is membership the wake machinery
; maintains, in the gate it is re-evaluated live on every pass.
; ----------------------------------------------------------------------------

(npc-task {@self take ?item}:?take-rel
  (tar @excl [k object] @object)
  (and
    (try
      (effects (check (or (empty (spatial (spatial @self left-hand) grip))
                          (empty (spatial (spatial @self right-hand) grip))))))
    (try
      (role @self (spatial ?item co-located @self)
        (when (empty (spatial (spatial @self right-hand) grip)))
        (effects (maintain-proposal {@self GRASP ?item (spatial @self right-hand)}))))
    (try
      (role @self (spatial ?item co-located @self)
        (when (empty (spatial (spatial @self left-hand) grip)))
        (when (not (empty (spatial (spatial @self right-hand) grip))))
        (effects (maintain-proposal {@self GRASP ?item (spatial @self left-hand)}))))
    (try
      (when {@self /succ GRASP ?item ? /caused_by ?take-rel})
      (effects (set-outcome ?take-rel /succ)))))
