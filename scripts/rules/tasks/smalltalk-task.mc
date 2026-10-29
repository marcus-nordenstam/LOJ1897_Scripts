; ----------------------------------------------------------------------------
; smalltalk ?talk ?partner - the SMALLTALK dialogue task: in the conversation ?talk @self remarks on
; the weather to ?partner (smalltalk-line, funcs/conversation.mc), once a talk. It is spent, a
; success, when he has no remark left and his remark has its answer. Proposed by smalltalk-unease
; (drivers/smalltalk-driver.mc); a remark said to him is answered by the respond driver.
; ----------------------------------------------------------------------------

(task {@self smalltalk ?talk ?partner}:?smalltalk
  (tar @excl [k conversation] @object)
  (aux [k human] @object)
  (and
    (try
      (role ?partner {?talk participant ?partner}
        (bind (smalltalk-line ?talk) ?remark)
        (when (and (substantial ?remark)
                   (none {@self tell ?remark ?partner /succ /caused_by ?smalltalk})
                   (not (awaits-smalltalk-answer ?talk ?partner))))
        (effects (maintain-proposal {@self tell ?remark ?partner} /quit-trying-on-fail))))
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (unsubstantial (smalltalk-line ?talk)) (not (awaits-smalltalk-answer ?talk ?partner))))
      (effects (set-outcome ?smalltalk /succ)))))
