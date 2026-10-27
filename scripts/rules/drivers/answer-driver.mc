; ----------------------------------------------------------------------------
; answer drivers - the REACTIVE drivers of the answer dialogue task: a line said to @self in his
; conversation that asks a line of him, and that nothing of his answers yet, is owed its answer
; (tasks/answer-task.mc). A question asked by a party of the talk; an opening called by a man who
; joined it by hailing him (the hail answers in drivers/answer-hail-driver.mc are for a caller who
; would take him out of the talk he is in).
; ----------------------------------------------------------------------------

(driver answer-question
  (role @self {@self converse ?talk}:?converse
    (role ?speaker {?speaker SAY ? @self /past}
                   {?speaker SAY (qs ? ? ?..) @self /past}:?line
                   -{@self tell ? ?speaker /succ /caused_by ?line}
      (when (and (in-conversation @self ?talk) (in-conversation ?speaker ?talk)))
      (declare-utility obligation)
      (effects (maintain-proposal {@self answer ?speaker ?line} /caused_by ?converse)))))

(driver greet-joiner
  (role @self {@self converse ?talk}:?converse
    (role ?speaker {?speaker SAY ? @self /past}
                   {?speaker SAY (formulaic ? opening-phrase ?..) @self /past}:?line
                   -{@self tell ? ?speaker /succ /caused_by ?line}
                   -{@self take-up ?speaker /succ /caused_by ?line}
                   -{@self turn-down ?speaker ? /succ /caused_by ?line}
      (when (and (in-conversation @self ?talk) (in-conversation ?speaker ?talk)))
      (declare-utility obligation)
      (effects (maintain-proposal {@self answer ?speaker ?line} /caused_by ?converse)))))
