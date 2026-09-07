; ----------------------------------------------------------------------------
; collect-applications ?wp - the recruiting officer's OFFICE post: fetch the job
; applications that have arrived in ?wp's incoming mail-stack. If @self does not know
; where that stack is, LOCATE it (wandering ?wp); once known, go to its room and lift the
; applications via take-applications. Concluded once the stack is swept this round. This
; is the work-side twin of read-mail (the HOME post): the home task keeps letters
; addressed to ME, this one keeps every application, whoever it names.
; ----------------------------------------------------------------------------

(npc-task {@self collect-applications ?wp}:?ca-rel
  (tar @excl structure)
  (and
    (try
      (role @self -{@self locate [k mail-stack] ?wp /succ}
                 -{@self locate [k mail-stack] ?wp /fail})
      (utility obligation)
      (effects (maintain-proposal {@self locate [k mail-stack] ?wp})))
    (try
      (role ?stk [k mail-stack] (spatial ?stk building ?wp)
                                (not (spatial ?stk co-located @self))
                                (spatial ?stk space): ?room)
      (effects (maintain-proposal {@self WALK ?room})))
    (try
      (role ?stk [k mail-stack] (spatial ?stk building ?wp)
                                (spatial ?stk co-located @self)
                                -{@self take-applications ?stk /succ /caused_by ?ca-rel})
      (utility obligation)
      (effects (maintain-proposal {@self take-applications ?stk})))
    (try
      (role ?stk [k mail-stack] (spatial ?stk building ?wp))
      (when {@self take-applications ?stk /succ /caused_by ?ca-rel})
      (effects (set-outcome ?ca-rel /succ)))
    (try
      (role @self {@self locate [k mail-stack] ?wp /fail})
      (effects (set-outcome ?ca-rel /fail)))))
