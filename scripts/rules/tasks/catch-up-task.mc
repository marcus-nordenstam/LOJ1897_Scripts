; ----------------------------------------------------------------------------
; catch-up ?friend - @self catches up with a friend: hails him unless they are talking already,
; tells him each piece of his news he does not know (news-for, funcs/conversation.mc), then asks
; what is new with him. Done when he has told it all and has the friend's reply; a friend who
; turns the hail down ends it /fail. The friend's answers and his own news are the general
; response's (drivers/respond-driver.mc). Proposed by catch-up-driver (drivers/catch-up-driver.mc).
; ----------------------------------------------------------------------------

(task {@self catch-up ?friend}:?catch-up
  (tar [k human] @object)
  (lint-waive task-no-preparation)
  (noncompete-set discourse)
  (success-cond (caught-up ?friend))
  (stable-or
    (try
      (when (not (engaged-with ?friend)))
      (effects (maintain-proposal {@self hail ?friend})))
    (try
      (role @self {@self hail ?friend /fail /caused_by ?catch-up}:?hail
        (when (hail-turned-down ?friend ?hail))
        (effects (set-outcome ?catch-up /fail))))
    (try
      (bind (news-for ?friend) ?news)
      (when (and (engaged-with ?friend) (substantial ?news)))
      (effects (maintain-proposal {@self tell (msg /utterable [/msg-class tidings] ?news) ?friend} /quit-trying-on-fail)))
    (try
      (when (and (engaged-with ?friend)
                 (unsubstantial (news-for ?friend))
                 (not (asked-news ?friend (conversation-of @self)))))
      (effects (maintain-proposal {@self tell (qs /utterable [/msg-class tidings] (pick-untold-belief /news @i)) ?friend}
                                  /quit-trying-on-fail)))))
