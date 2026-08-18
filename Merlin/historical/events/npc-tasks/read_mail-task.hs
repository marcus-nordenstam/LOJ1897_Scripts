; ----------------------------------------------------------------------------
; read_mail ?prem - fetch and read @self's mail at ?prem's mailbox. If @self does not know
; where ?prem's incoming mail_stack is, LOCATE it (wandering ?prem); once known, go to its
; room, lift the letters addressed to @self via take_my_letters, and read each held one.
; Concluded once the stack is swept this round and @self's hands are empty of letters. The
; stack binds SCOPED to ?prem via (in-building ?stk ?prem). NO give-up try: an interrupted
; round RESUMES on the next premises visit (the rungs propose nothing from afar).
; Driver + saturation probe stay in read_mail_think.hs.
; ----------------------------------------------------------------------------

(npc-task {@self read_mail ?prem}:?rm
  (tar @excl structure)
  (and
    (try
      (when (none {@self locate [k mail_stack] ?prem /succ}))
      (utility errand)
      (effects (debug-print "RM_LOC") (begin-proposal {@self locate [k mail_stack] ?prem})))
    (try
      (role ?stk [k mail_stack] (in-building ?stk ?prem)
                                (not (co-present ?stk @self)))
      (when (location ?stk): ?room)
      (effects (maintain-proposal {@self WALK ?room})))
    (try
      (role ?stk [k mail_stack] (in-building ?stk ?prem)
                                (co-present ?stk @self))
      (when (none {@self take_my_letters ?stk /caused_by ?rm /ever}))
      (utility errand)
      (effects (debug-print "RM_TAKE")
               (begin-proposal {@self take_my_letters ?stk})))
    (try
      (role ?ltr [k letter] (spatial @self hold))
      (effects (maintain-proposal {@self READ ?ltr})))
    (try
      (role ?stk [k mail_stack] (in-building ?stk ?prem))
      (when (and (believes {@self take_my_letters ?stk /succ /caused_by ?rm})
                 (empty (spatial @self hold [k letter]))))
      (effects (debug-print "RM_DONE") (set-outcome ?rm succ)))
    (try
      (effects (debug-print "RM_P_TASK prem=?prem")))))
