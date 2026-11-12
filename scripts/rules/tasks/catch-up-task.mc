; ----------------------------------------------------------------------------
; catch-up ?friend - @self catches up with a friend: hails him unless they are talking already,
; tells him each piece of his news he does not know (news-for, funcs/conversation.mc), then asks
; what is new with him. Done when he has told it all and has the friend's reply; a friend who
; turns the hail down ends it /fail. The friend's answers and his own news are the general
; response's (drivers/respond-driver.mc). Proposed by catch-up-driver (drivers/catch-up-driver.mc).
; ----------------------------------------------------------------------------

(task {@self catch-up ?friend}:?catch-up
  (tar @excl [k human] @object)
  (lint-waive task-no-preparation)
  (category social (scope (talk-between ?friend)))
  (hosts reply enter-conversation)
  (success-cond (caught-up ?friend))
  (stable-or
    (try
      (lod unpresented)
      (when (unsubstantial (news-for ?friend)))
      (effects (set-outcome ?catch-up /succ)))
    (try
      (lod presented)
      (when (and (not (conversing-with ?friend)) (hailable ?friend)))
      (effects (maintain-proposal {@self hail ?friend})))
    ; One activation per piece of news, so a piece told, or no longer true, is a withdrawn tell.
    (try
      (lod presented)
      (belief ?news {@self news ?told}:?news
                  (speech-worthy ?told ?friend)
                  (select (policy first-match))
        (when (conversing-with ?friend))
        (effects
          (maintain-proposal {@self tell (msg /utterable /tidings [] ?told) ?friend} /quit-trying-on-fail))))
    (try
      (lod unpresented)
      (belief-list ?news-items {@self news ?told}:?news
                   (speech-worthy ?told ?friend)
        (effects
          (maintain-proposal {@self tell (msg /utterable /tidings [] ?news-items.target) ?friend}
                             /quit-trying-on-fail))))
    (try
      (lod presented)
      (when (and (conversing-with ?friend)
                 (unsubstantial (news-for ?friend))
                 (not (asked-news ?friend (conversation-of @self)))))
      (effects (maintain-proposal {@self tell (qs /utterable /tidings [] (news-for @self)) ?friend}
                                  /quit-trying-on-fail)))))
