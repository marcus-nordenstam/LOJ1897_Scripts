; ----------------------------------------------------------------------------
; want-to-know-driver - wondering about a fact, with a man here who could tell him it (askable,
; funcs/conversation.mc), @self sets out to find it out (tasks/find-out-task.mc), caused by the
; wondering, and in a talk asks (drivers/ask-wonder-driver.mc). The task is done when he knows; the
; wondering ends then too (thinks/wonder-mealtimes-think.mc for the supper hour). With nobody here
; to ask he still wonders, and sets out again once someone who could know is - one he is talking with,
; or may hail: a man who turned his hail down is asked once he seeks @self out. Whom he asks is
; find-out's to choose: this needs only one such man here, so it casts the first.
; ----------------------------------------------------------------------------

(driver want-to-know-driver
  (belief ?wonder {@self wonder ?fact}:?wonder
    (role ?who {?who isa [k human]}
               (neq ?who @self)
               (spatial ?who co-located @self)
               (askable ?who ?fact)
               (or (conversing-with ?who) (hailable ?who))
               (select (policy first-match))
      ; Learning a thing one wonders about beats settling into a leisure hour.
      (declare-utility want (above rest))
      (effects (maintain-proposal {@self find-out ?fact} /caused_by ?wonder)))))
