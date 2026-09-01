; ----------------------------------------------------------------------------
; read-mail ?prem - fetch and read @self's mail at ?prem's mailbox. If @self does not know
; where ?prem's incoming mail-stack is, LOCATE it (wandering ?prem); once known, go to its
; room, lift the letters addressed to @self via take-my-letters, and read each held one.
; Concluded once the stack is swept this round and @self's hands are empty of letters. The
; stack binds SCOPED to ?prem via (spatial ?stk building ?prem). NO give-up try: an interrupted
; round RESUMES on the next premises visit (the rungs propose nothing from afar).
; Driver + saturation probe stay in read_mail_think.hs.
; ----------------------------------------------------------------------------

(npc-task {@self read-mail ?prem}:?rm-rel
  (tar @excl structure)
  (and
    (try
      (when -{@self locate [k mail-stack] ?prem /succ})
      (utility errand)
      (effects (begin-proposal {@self locate [k mail-stack] ?prem})))
    (try
      (role ?stk [k mail-stack] (spatial ?stk building ?prem)
                                (not (spatial ?stk co-located @self)))
      (when (spatial ?stk space): ?room)
      (effects (maintain-proposal {@self WALK ?room})))
    (try
      (role ?stk [k mail-stack] (spatial ?stk building ?prem)
                                (spatial ?stk co-located @self))
      (when -{@self take-my-letters ?stk /caused_by ?rm-rel /ever})
      (utility errand)
      (effects
               (begin-proposal {@self take-my-letters ?stk})))
    (try
      (role ?ltr [k letter] (spatial @self hold))
      (effects (maintain-proposal {@self READ ?ltr})))
    (try
      (role ?stk [k mail-stack] (spatial ?stk building ?prem))
      (when (and {@self take-my-letters ?stk /succ /caused_by ?rm-rel}
                 (empty (spatial @self hold [k letter]))))
      (effects (set-outcome ?rm-rel /succ)))
    (try
      (effects ))))
