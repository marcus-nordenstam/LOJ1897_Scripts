; ----------------------------------------------------------------------------
; flirt ?partner ?talk - the FLIRTING dialogue task: @self pays ?partner, whom he fancies, his
; compliment. Presented, in the conversation ?talk, once a talk; unpresented there is no talk, and
; he says it to her straight out. It is spent, a success, when he has flirted or fancies ?partner no
; longer. Seen while it runs (obs), it tells whoever sees it - ?partner herself or an onlooker -
; that he likely fancies her (reflexes/flirt-suggests-fancy.mc). Proposed by the flirt drivers
; (drivers/flirt-driver.mc); a flirt said to him is answered by the respond drivers.
; ----------------------------------------------------------------------------

(task {@self flirt ?partner ?talk}:?flirt
  (obs)
  (category social (scope ?talk))
  (hosts reply enter-conversation)
  (tar @excl [k human] @object)
  (aux ?)
  (and
    (try
      (lod presented)
      (role ?partner {@self fancy|desire|crave ?partner}
        (when (and (not (flirted-in ?talk)) (not (awaits-flirt-answer ?talk ?partner))))
        (effects (maintain-proposal {@self tell (formulaic [/msg-class flirtation] flirt compliment) ?partner}
                                    /quit-trying-on-fail))))
    (try
      (lod presented)
      (lint-waive cacheable-read-in-when)
      (when (and (or (flirted-in ?talk) (none {@self fancy|desire|crave ?partner}))
                 (not (awaits-flirt-answer ?talk ?partner))))
      (effects (set-outcome ?flirt /succ)))
    (try
      (lod unpresented)
      (when (none {@self tell ? ?partner /succ /caused_by ?flirt}))
      (effects (maintain-proposal {@self tell (formulaic [/msg-class flirtation] flirt compliment) ?partner}
                                  /quit-trying-on-fail)))
    (try
      (lod unpresented)
      (belief {@self tell ? ?partner /succ /caused_by ?flirt}
        (effects (set-outcome ?flirt /succ))))))
