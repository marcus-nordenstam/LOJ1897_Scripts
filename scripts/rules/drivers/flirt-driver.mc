; ----------------------------------------------------------------------------
; flirt drivers - the drivers of the flirting dialogue task (tasks/flirt-task.mc).
; flirt-fancy is PROACTIVE: in a talk with someone he fancies, @self pays her his compliment.
; return-flirt is REACTIVE: a flirt said to @self in his talk is owed its answer, as a question is
; (drivers/answer-driver.mc), his flirt caused by the presence and by the line it answers.
; ----------------------------------------------------------------------------

(driver flirt-fancy
  (role @self {@self converse ?talk}:?converse
    (role ?partner {@self fancy|desire|crave ?partner}:?fancy
      (when (and (in-conversation @self ?talk)
                 (in-conversation ?partner ?talk)
                 (not (flirted-in ?talk))))
      (declare-utility want)
      (effects (maintain-proposal {@self flirt ?talk ?partner} /caused_by ~[?converse ?fancy])))))

(driver return-flirt
  (role @self {@self converse ?talk}:?converse
    (role ?speaker {?speaker SAY (formulaic ~[/msg-class flirtation] flirt compliment) @self /past}:?line
                   -{@self tell ? ?speaker /succ /caused_by ?line}
      (when (and (in-conversation @self ?talk)
                 (in-conversation ?speaker ?talk)
                 (happened-since ?line ?converse)))
      (declare-utility obligation)
      (effects (maintain-proposal {@self flirt ?talk ?speaker} /caused_by ~[?converse ?line])))))
