; ----------------------------------------------------------------------------
; smalltalk-unease-driver (driver) - ill at ease in a talk with someone he is not close to
; (thinks/classify/classify-unease.mc), @self makes his remark on the weather to him
; (tasks/smalltalk-task.mc). A remark said to him is answered by the respond driver.
; ----------------------------------------------------------------------------

(driver smalltalk-unease-driver
  (lod presented)
  (role ?talk {?talk participant @self} {@self unease ?talk}:?unease -{@self company [k crowded]}
    (role ?partner (bb-public-members ?talk bbk-participant)
                   (neq ?partner @self)
                   (holds-part ?partner ?talk)
      (role ?town {?town sky|rain|snow|fog|wind ?}
        (when (and (eq ?town (spatial @self town))
                   (substantial (smalltalk-line ?talk))))
        (declare-utility want)
        (effects (maintain-proposal {@self smalltalk ?partner ?talk} /caused_by ?unease))))))
