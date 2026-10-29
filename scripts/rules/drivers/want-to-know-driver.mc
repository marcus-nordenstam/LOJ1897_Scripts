; ----------------------------------------------------------------------------
; want-to-know-driver - wondering about a fact, and knowing a man who could tell him it (askable,
; funcs/conversation.mc), @self sets out to find it out (tasks/find-out-task.mc), caused by the
; wondering, and in a talk asks (drivers/ask-wonder-driver.mc). The task is done when he knows; the
; wondering ends then too (thinks/wonder-mealtimes-think.mc for the supper hour). With nobody left
; to ask he still wonders, and sets out again once he learns of someone who could know.
; ----------------------------------------------------------------------------

(driver want-to-know-driver
  (role @self {@self wonder ?fact}:?wonder
    (role ?who {?who isa [k human]}
               (neq ?who @self)
      (when (askable ?who ?fact))
      ; Learning a thing one wonders about beats settling into a leisure day.
      (declare-utility idle (above rest))
      (effects (maintain-proposal {@self find-out ?fact} /caused_by ?wonder)))))
