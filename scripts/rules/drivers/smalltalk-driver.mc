; ----------------------------------------------------------------------------
; smalltalk drivers - the drivers of the smalltalk dialogue task (tasks/smalltalk-task.mc).
; smalltalk-unease is PROACTIVE: ill at ease in a talk with someone he is not close to
; (thinks/classify/classify-unease.mc), @self makes his remark on the weather to him.
; return-smalltalk is REACTIVE: a remark said to @self in his talk is owed its answer, as a question
; is (drivers/answer-driver.mc), his smalltalk caused by the presence and by the line it answers.
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

(driver return-smalltalk
  (role @self {@self converse ?talk}:?converse
    (role ?speaker {?speaker SAY (msg ~[/msg-class smalltalk] ?..) @self /past}:?line
                   -{@self tell ? ?speaker /succ /caused_by ?line}
      (when (and (in-conversation @self ?talk)
                 (in-conversation ?speaker ?talk)
                 (happened-since ?line ?converse)))
      (declare-utility obligation)
      (effects (maintain-proposal {@self smalltalk ?talk ?speaker} /caused_by ~[?converse ?line])))))
