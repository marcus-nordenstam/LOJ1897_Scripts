; ----------------------------------------------------------------------------
; read-mail ?prem - fetch and read @self's mail at ?prem's mailbox, whose mail-stack @self
; knows (its driver locates an unknown one first): go to its room, lift the letters addressed
; to @self via take-my-letters, and read each held one.
; Concluded once the stack is swept this round and @self's hands are empty of letters. The
; stack binds SCOPED to ?prem via (within-place ?stk ?prem). NO give-up try: an interrupted
; round RESUMES on the next premises visit (the rungs propose nothing from afar).
; Driver + saturation probe stay in read_mail_think.mc.
; ----------------------------------------------------------------------------

(task {@self read-mail ?prem}:?read-mail
  (tar @excl [k building|unit] @object)
  (and
    (try
      (role ?stk [k mail-stack] (within-place ?stk ?prem)
                                (not (spatial @self can-reach ?stk))
        (when (spatial ?stk space))
        (effects (maintain-proposal {@self go-to ?stk}))))
    (try
      (role ?stk [k mail-stack] (within-place ?stk ?prem)
                                (spatial @self can-reach ?stk)
                                -{@self take-my-letters ?stk /succ /caused_by ?read-mail}
        (effects
                 (maintain-proposal {@self take-my-letters ?stk}))))
    ; The reading and the re-filing are the ROUND's, not this task's: take-my-letters hands
    ; the browse a body that reads each letter of his where it lies and puts it straight
    ; back. Doing it from up here is what broke the round - these rungs saw the letter the
    ; browse was holding in flight, read it, and filed it away underneath the browse, which
    ; then waited for ever to re-file a letter no longer in his hand.
    (try
      (role ?stk [k mail-stack] (within-place ?stk ?prem)
        (when (and {@self take-my-letters ?stk /succ /caused_by ?read-mail}
                   (empty (spatial @self hold [k letter]))))
        (effects (set-outcome ?read-mail /succ))))))
