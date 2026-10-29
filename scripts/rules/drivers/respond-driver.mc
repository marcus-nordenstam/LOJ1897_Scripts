; ----------------------------------------------------------------------------
; respond-driver (driver) - THE reactive driver of conversation: a line a party of @self's conversation
; said to him since he joined it, of a kind that calls for a response (owes-response,
; funcs/conversation.mc), and that nothing of his answers yet, is owed its response
; (tasks/respond-task.mc). An opening he took up or turned down was answered by that (the hail
; answers in drivers/answer-hail-driver.mc are for a caller outside the talk he is in).
; ----------------------------------------------------------------------------

(driver respond-driver
  (role @self {@self converse ?talk}:?converse
    (role ?speaker {?speaker SAY ?msg @self /past}:?line
                   -{@self tell ? ?speaker /succ /caused_by ?line}
                   -{@self take-up ?speaker /succ /caused_by ?line}
                   -{@self turn-down ?speaker ? /succ /caused_by ?line}
      (bind (any {?talk participant @self}) ?part)
      (when (and (in-conversation @self ?talk)
                 (in-conversation ?speaker ?talk)
                 (happened-since ?line ?part)
                 (owes-response ?msg)))
      (declare-utility obligation)
      (effects (maintain-proposal {@self respond ?speaker ?line} /caused_by ?converse)))))
