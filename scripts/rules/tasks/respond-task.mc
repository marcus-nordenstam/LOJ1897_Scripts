; ----------------------------------------------------------------------------
; respond ?speaker ?line - the RESPONSE dialogue task: @self says the one line ?speaker's heard
; ?line calls for, caused by it (reply-to, funcs/conversation.mc): a question answered from his
; own mind - "I don't know" when he does not know, a refusal when the answer is closer than he
; holds ?speaker (withholds) - an opening greeted back, a flirt answered, a remark met, tidings
; met with his own or received. Proposed by the respond driver (drivers/respond-driver.mc), and
; by a hail for the opening of a man hailing him too; it succeeds when the line is said, or at
; once when the line calls for nothing he can say.
; ----------------------------------------------------------------------------

(task {@self respond ?speaker ?line}:?respond
  (tar @excl [k human] @object)
  (aux ?)
  (success-cond {@self tell ? ?speaker /succ /caused_by ?line})
  (preemptive-or
    (try
      (role ?speaker {?speaker SAY ?msg @self /past}:?line
        (when (and (is-qs ?msg) (withholds ?msg ?speaker)))
        (effects (maintain-proposal {@self tell (formulaic [/msg-class reply] refusal answer) ?speaker} /caused_by ?line /quit-trying-on-fail))))
    (try
      (role ?speaker {?speaker SAY ?msg @self /past}:?line
        (bind (reply-to ?msg ?speaker) ?reply)
        (when (substantial ?reply))
        (effects (maintain-proposal {@self tell ?reply ?speaker} /caused_by ?line /quit-trying-on-fail))))
    (try
      (role ?speaker {?speaker SAY ?msg @self /past}:?line
        (effects (set-outcome ?respond /succ))))))
