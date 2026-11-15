; ----------------------------------------------------------------------------
; respond-driver (driver) - THE reactive driver of conversation: a line a party of @self's conversation
; said to him since he joined it - each speaker's last - of a kind that calls for a response, owes him
; its response (reflexes/obligation-respond.mc); while it does not wait on his asking back
; (owes-response, funcs/conversation.mc) and nothing of his answers it yet, he responds
; (tasks/respond-task.mc), one at a time: the oldest line owed is answered first. An opening he
; took up or turned down was answered by that (the hail answers in drivers/answer-hail-driver.mc
; are for a caller outside the talk he is in).
; ----------------------------------------------------------------------------

(driver respond-driver
  (lod presented)
  (role ?talk {?talk participant @self}:?part
    (role ?speaker {@self obligation {@self respond ?speaker ?line} ?speaker}:?owed
                   (owes-response ?line)
                   -{@self respond ?speaker ?line /succ}
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

; respond-direct-driver (driver) - unpresented there is no talk and no decorum: only a line owed
; wherever it is said - a question or a flirt - is answered, the answer or the courtship's flirt back
; or rebuff, straight to the one who said it (tasks/respond-task.mc), the oldest first.
(driver respond-direct-driver
  (lod unpresented)
  (role ?speaker {@self obligation {@self respond ?speaker ?line} ?speaker}:?owed
                 (has-facet (line-kind ?line) answer-owed)
                 (empty (unresolved-in ?line))
                 -{@self tell ? ?speaker /succ /caused_by ?line}
                 (select (score (- 0 (elapsed /seconds (start-time ?line)))) (policy argmin))
    (declare-utility obligation)
    (effects (maintain-proposal {@self respond ?speaker ?line}))))
