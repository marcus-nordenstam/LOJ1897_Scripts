; ----------------------------------------------------------------------------
; get-acquainted ?other - @self tells an acquaintance about himself: hails him unless they are
; talking already, then tells him each aspect of himself he does not know (disclosure-for,
; funcs/conversation.mc). Done when there is none left for him; a man who turns the hail down
; ends it /fail. What he tells back is his own get-acquainted. Proposed by get-acquainted-driver
; (drivers/get-acquainted-driver.mc).
; ----------------------------------------------------------------------------

(task {@self get-acquainted ?other}:?get-acquainted
  (tar @excl [k human] @object)
  (lint-waive task-no-preparation)
  (category social (scope (talk-between ?other)))
  (hosts reply enter-conversation)
  (success-cond (unsubstantial (disclosure-for ?other)))
  (stable-or
    (try
      (when (and (not (conversing-with ?other)) (hailable ?other)))
      (effects (maintain-proposal {@self hail ?other})))
    (try
      (role @self {@self (facet-labels self-disclosable) ?}:?aspect
                  (speech-worthy ?aspect ?other)
                  (select (policy first-match))
        (when (conversing-with ?other))
        (effects (maintain-proposal {@self tell (msg /utterable [/msg-class tidings] ?aspect) ?other} /quit-trying-on-fail))))))
