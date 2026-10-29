; ----------------------------------------------------------------------------
; smalltalk-unease (driver) - ill at ease in a talk with someone he is not close to
; (thinks/classify/classify-unease.mc), @self makes his remark on the weather to him
; (tasks/smalltalk-task.mc). A remark said to him is answered by the respond driver.
; ----------------------------------------------------------------------------

(driver smalltalk-unease
  (role @self {@self converse ?talk}:?converse {@self unease ?talk}:?unease
    (role ?partner {?talk participant ?partner}
                   (neq ?partner @self)
      (role ?town {?town sky|rain|snow|fog|wind ?}
        (when (and (eq ?town (spatial @self town))
                   (in-conversation ?partner ?talk)
                   (substantial (smalltalk-line ?talk))))
        (declare-utility want)
        (effects (maintain-proposal {@self smalltalk ?talk ?partner} /caused_by ~[?converse ?unease]))))))
