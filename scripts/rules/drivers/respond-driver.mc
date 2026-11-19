; ----------------------------------------------------------------------------
; respond-driver (driver) - THE reactive driver of talk: a line a participant of @self's talk
; said to him since he joined it, of a kind that asks for a response, obliges him to respond once
; nothing it leaves unsaid blocks it (owe-reply, funcs/talk.mc); while nothing of his answers it yet,
; he responds (tasks/respond-task.mc), one at a time: the oldest line due is answered first. An opening he
; took up or turned down was answered by that (the hail answers in drivers/answer-hail-driver.mc
; are for a hailer outside the talk he is in).
; ----------------------------------------------------------------------------

(driver respond-driver
  (lod presented)
  (role ?talk {?talk participant @self}:?part
    (role ?speaker {@self obligation {@self respond ?speaker ?line} ?speaker}:?owed
                   -{@self respond ?speaker ?line /succ}
                   (in-talk ?speaker ?talk)
                   (happened-since ?line ?part)
                   ; argmin: a line heard in the second it was said is 0 seconds old, and argmax never picks 0.
                   (select (score (- 0 (elapsed /seconds (start-time ?line)))) (policy argmin))
      (when (in-talk @self ?talk))
      (declare-utility obligation)
      (effects (maintain-proposal {@self respond ?speaker ?line})))))

; respond-direct-driver (driver) - unpresented there is no talk and no decorum: only a line owed
; wherever it is said - a question or a flirt - is answered, the answer or the courtship's flirt back
; or rebuff, straight to the one who said it (tasks/respond-task.mc), the oldest first.
(driver respond-direct-driver
  (lod unpresented)
  (role ?speaker {@self obligation {@self respond ?speaker ?line} ?speaker}:?owed
                 (has-facet (line-kind ?line) answer-owed)
                 (empty (unresolved-in ?line))
                 (select (score (- 0 (elapsed /seconds (start-time ?line)))) (policy argmin))
    (declare-utility obligation)
    (effects (maintain-proposal {@self respond ?speaker ?line}))))
