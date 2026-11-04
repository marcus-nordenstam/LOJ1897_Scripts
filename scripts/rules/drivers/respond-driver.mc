; ----------------------------------------------------------------------------
; respond-driver (driver) - THE reactive driver of conversation: a line a party of @self's conversation
; said to him since he joined it - each speaker's last - of a kind that calls for a response (owes-response,
; funcs/conversation.mc), and that nothing of his answers yet, is owed its response
; (tasks/respond-task.mc), one at a time: the oldest line owed is answered first. An opening he
; took up or turned down was answered by that (the hail answers in drivers/answer-hail-driver.mc
; are for a caller outside the talk he is in).
; ----------------------------------------------------------------------------

(driver respond-driver
  (role ?talk {?talk participant @self}:?part
    (role ?speaker {?speaker SAY ?msg @self /past /most_recent}:?line
                   (owes-response ?msg)
                   -{@self tell ? ?speaker /succ /caused_by ?line}
                   -{@self take-up ?speaker /succ /caused_by ?line}
                   -{@self turn-down ?speaker ? /succ /caused_by ?line}
                   (in-conversation ?speaker ?talk)
                   (happened-since ?line ?part)
                   ; argmin: a line heard in the second it was said is 0 seconds old, and argmax never picks 0.
                   (select (score (- 0 (elapsed /seconds (start-time ?line)))) (policy argmin))
      (when (in-conversation @self ?talk))
      (declare-utility obligation)
      (effects (maintain-proposal {@self respond ?speaker ?line} /caused_by ?part)))))
