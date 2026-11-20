; ----------------------------------------------------------------------------
; respond ?speaker ?line - the RESPONSE dialogue task: @self says the one line ?speaker's heard
; ?line asks for, caused by it (reply-to, funcs/talk.mc): a question answered from his
; own mind - "I don't know" when he does not know, a refusal when the answer is closer than he
; holds ?speaker (withholds) - a flirt answered, a remark met, tidings met with his own or
; received, a statement met with what he knew of it and felt about it. Proposed by the respond
; driver (drivers/respond-driver.mc); it succeeds when the line is said, or at
; once when the line asks for nothing he can say, and with that he is no longer obliged to respond
; to it (reply-settled, funcs/talk.mc).
; ----------------------------------------------------------------------------

(task {@self respond ?speaker ?line}:?respond
  (belief-timeout 15 min)
  (category reply)
  (tar @excl [k human] @object)
  (aux ?)
  (preemptive-or
    (try
      (belief {@self SAY ? ?speaker /succ /caused_by ?respond}
        (effects
          (reply-settled ?speaker ?line)
          (set-outcome ?respond /succ))))
    (try
      (role ?speaker {?speaker SAY ?msg @self /past}:?line
        (when (and (matches ?msg (qs ?..)) (withholds ?msg ?speaker)))
        (bind (formulaic [] refusal answer) ?refusal)
        (effects
          (bind (prefaced (as-reply-to ?refusal ?line) ?line) ?said)
          (maintain-intent {@self intent {@self SAY ?said ?speaker}}))))
    (try
      (role ?speaker {?speaker SAY ?msg @self /past}:?line
        (bind (reply-to ?line ?speaker) ?reply)
        (when (substantial ?reply))
        (effects
          (bind (prefaced (as-reply-to ?reply ?line) ?line) ?said)
          (maintain-intent {@self intent {@self SAY ?said ?speaker}}))))
    (try
      (role ?speaker {?speaker SAY ?msg @self /past}:?line
        (effects
          (reply-settled ?speaker ?line)
          (set-outcome ?respond /succ))))))
