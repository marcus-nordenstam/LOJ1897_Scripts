; ----------------------------------------------------------------------------
; flirt ?partner ?talk - the FLIRTING dialogue task: @self pays ?partner, whom he fancies, his
; compliment. Presented, in the talk ?talk, once a talk; unpresented there is no talk, and
; he says it to her straight out. It is spent, a success, when he has flirted or fancies ?partner no
; longer. Seen while it runs (obs), it tells whoever sees it - ?partner herself or an onlooker -
; that he likely fancies her (reflexes/flirt-suggests-fancy.mc). Proposed by the flirt drivers
; (drivers/flirt-driver.mc); a flirt said to him is answered by the respond drivers.
; ----------------------------------------------------------------------------

(task {@self flirt ?partner ?talk}:?flirt
  (belief-timeout 30 min)
  (obs)
  (category social (scope ?talk))
  (hosts reply enter-talk)
  (tar @excl [k human] @object)
  (aux ?)
  (and
    (try
      (role ?partner {@self fancy|desire|crave ?partner}
        (when (and (not (flirted-in ?talk)) (not (awaits-answer ?talk ?partner flirtation))))
        (effects (maintain-intent {@self intent {@self SAY (formulaic [] compliment) ?partner}}))))
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (or (flirted-in ?talk) (none {@self fancy|desire|crave ?partner}))
                 (not (awaits-answer ?talk ?partner flirtation))))
      (effects (set-outcome ?flirt /succ)))))
