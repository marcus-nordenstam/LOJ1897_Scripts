; ----------------------------------------------------------------------------
; flirt ?talk ?partner - the FLIRTING dialogue task: in the conversation ?talk @self pays ?partner,
; whom he fancies, his compliment, once a talk. It is spent, a success, when he has flirted or
; fancies ?partner no longer, and his flirt has its answer. Proposed by flirt-fancy
; (drivers/flirt-driver.mc); a flirt said to him is answered by the respond driver.
; ----------------------------------------------------------------------------

(task {@self flirt ?talk ?partner}:?flirt
  (tar @excl [k conversation] @object)
  (aux [k human] @object)
  (and
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
