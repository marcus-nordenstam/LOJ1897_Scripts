; ----------------------------------------------------------------------------
; answer ?speaker ?line - the ANSWER dialogue task: @self says the one line ?speaker's heard ?line
; asks of him, caused by it. A question is answered from his own mind - "I don't know" when he
; does not know, a refusal when the answer is closer than he holds ?speaker (withholds); an opening
; from a man who joined his conversation by hailing him is greeted back. Proposed by the reactive
; answer drivers (drivers/answer-driver.mc); it succeeds when the line is said.
; ----------------------------------------------------------------------------

(task {@self answer ?speaker ?line}:?answer
  (tar @excl [k human] @object)
  (aux ?)
  (preemptive-or
    (try
      (when {@self tell ? ?speaker /succ /caused_by ?line})
      (effects (set-outcome ?answer /succ)))
    (try
      (role ?speaker {?speaker SAY ?msg @self /past}:?line
        (when (and (is-qs ?msg) (withholds ?msg ?speaker)))
        (effects (maintain-proposal {@self tell (formulaic [] refusal answer) ?speaker} /caused_by ?line /quit-trying-on-fail))))
    (try
      (role ?speaker {?speaker SAY ?msg @self /past}:?line
        (when (is-qs ?msg))
        (effects
          (bind (answer-to ?msg ?speaker) ?reply)
          (maintain-proposal {@self tell ?reply ?speaker} /caused_by ?line /quit-trying-on-fail))))
    (try
      (role ?speaker {?speaker SAY ?msg @self /past}:?line
        (effects
          (bind (hail-response ?msg) ?response)
          (maintain-proposal {@self tell ?response ?speaker} /caused_by ?line /quit-trying-on-fail))))))
