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
    ; The locate's own /fail is the "no mail-stack here" record, exactly as find-building's is for
    ; seek_board_find - without reading it this rung re-proposes the search for ever.
    (try
      (when (and -{@self locate [k mail-stack] ?prem /succ}
                 -{@self locate [k mail-stack] ?prem /fail}))
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
    ; The search concluded that ?prem holds no mail-stack: there is no round to run here, so the
    ; task fails rather than holding its band while re-proposing a search that already answered.
    (try
      (when {@self locate [k mail-stack] ?prem /fail})
      (effects (set-outcome ?rm-rel /fail)))
    (try
      (effects ))))
