; ----------------------------------------------------------------------------
; smalltalk ?partner ?talk - the SMALLTALK dialogue task: in the talk ?talk @self remarks on
; the weather to ?partner (smalltalk-line, funcs/talk.mc), once a talk. It is spent, a
; success, when he has no remark left and his remark has its answer. Proposed by smalltalk-unease
; (drivers/smalltalk-driver.mc); a remark said to him is answered by the respond driver.
; ----------------------------------------------------------------------------

(task {@self smalltalk ?partner ?talk}:?smalltalk
  (belief-timeout 30 min)
  (lod presented)
  (category social (scope ?talk))
  (hosts reply enter-talk)
  (tar @excl [k human] @object)
  (aux [k talk] @object)
  (and
    (try
      (bind (smalltalk-line ?talk) ?remark)
      (when (and (holds-part ?partner ?talk)
                 (none {@self SAY ? ?partner /succ /caused_by ?smalltalk})
                 (substantial ?remark)
                 (not (awaits-answer ?talk ?partner smalltalk))))
      (effects (maintain-intent {@self intent {@self SAY ?remark ?partner}})))
    (try
      (lint-waive cacheable-read-in-when)
      (when (and (unsubstantial (smalltalk-line ?talk)) (not (awaits-answer ?talk ?partner smalltalk))))
      (effects (set-outcome ?smalltalk /succ)))))
