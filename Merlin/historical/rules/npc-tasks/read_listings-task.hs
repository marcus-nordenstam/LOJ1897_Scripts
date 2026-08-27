; ----------------------------------------------------------------------------
; read_listings ?stack - browse a public register stack and ADOPT every listing's
; writing as beliefs. The physical READ twin of the retired read-public-register
; global scan: @self must be AT ?stack (walk to its room if not), then the generic
; stack_browse surfaces each doc into hand one at a time; per surfaced doc @self
; READS it (adopt-msg the writing sentence -> belief) and marks it handled so
; browse re-files it. Concludes when the browse round concludes. Modelled on
; take_my_letters (the keep/handle browse consumer) - here every doc is read then
; handled, none kept. NO away rung: an interrupted round RESUMES at the stack.
; ----------------------------------------------------------------------------

(npc-task {@self read_listings ?stack}:?rl-rel
  (tar @excl stack)
  (and
    (try
      (role ?stk [k stack] (= ?stk ?stack)
            (not (spatial ?stk co-located @self)))
      (when (spatial ?stk space): ?room)
      (effects (debug-print "RL_WALK") (maintain-proposal {@self WALK ?room})))
    (try
      (when (and (spatial ?stack co-located @self)
                 (none {@self stack_browse ?stack /caused_by ?rl-rel /ever})))
      (utility errand)
      (effects (debug-print "RL_BROWSE")
               (begin-proposal {@self stack_browse ?stack})))
    (try
      (role ?doc [k document] (spatial @self hold)
            (= (bb-read ?doc browse-status) pending))
      (effects
        (debug-print "RL_READ doc=?doc")
        (adopt-msg (attr ?doc writing))
        (bb-write ?doc browse-status handled)))
    (try
      (when (any {@self stack_browse ?stack /succ /caused_by ?rl-rel}))
      (effects (debug-print "RL_DONE") (set-outcome ?rl-rel succ)))
    (try
      (effects (debug-print "RL_P_TASK stk=?stack")))))
