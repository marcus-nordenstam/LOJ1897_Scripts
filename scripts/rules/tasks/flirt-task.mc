; ----------------------------------------------------------------------------
; flirt ?talk ?partner - the FLIRTING dialogue task: in the conversation ?talk @self pays ?partner,
; whom he fancies, his compliment, and answers a flirt of ?partner's as his motives choose
; (flirt-reply, funcs/conversation.mc), the answer caused by the flirt. It is spent, a success, when
; he has flirted or fancies ?partner no longer, and no flirt of ?partner's in the talk is unanswered.
; Proposed by flirt-fancy and return-flirt (drivers/flirt-driver.mc).
; ----------------------------------------------------------------------------

(task {@self flirt ?talk ?partner}:?flirt
  (tar @excl [k conversation] @object)
  (aux [k human] @object)
  (and
    (try
      (role ?partner {?partner SAY (formulaic ~[/msg-class flirtation] flirt compliment) @self /past}:?line
                     -{@self tell ? ?partner /succ /caused_by ?line}
        (bind (any {?talk participant @self}) ?part)
        (bind (flirt-reply ?partner) ?reply)
        (when (happened-since ?line ?part))
        (effects (maintain-proposal {@self tell ?reply ?partner} /caused_by ?line /quit-trying-on-fail))))
    (try
      (role ?partner {@self fancy|desire|crave ?partner}
        (when (and (not (flirted-in ?talk)) (not (awaits-flirt-answer ?talk ?partner))))
        (effects (maintain-proposal {@self tell (formulaic [/msg-class flirtation] flirt compliment) ?partner}
                                    /quit-trying-on-fail))))
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (or (flirted-in ?talk) (none {@self fancy|desire|crave ?partner}))
                 (not (awaits-flirt-answer ?talk ?partner))))
      (effects (set-outcome ?flirt /succ)))))
