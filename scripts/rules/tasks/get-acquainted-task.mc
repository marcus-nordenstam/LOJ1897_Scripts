; ----------------------------------------------------------------------------
; get-acquainted ?other - @self tells an acquaintance about himself: hails him unless they are
; talking already, then tells him each aspect of himself he does not know (disclosure-for,
; funcs/conversation.mc). Done when there is none left for him; a man who turns the hail down
; ends it /fail. What he tells back is his own get-acquainted. Proposed by get-acquainted-driver
; (drivers/get-acquainted-driver.mc).
; ----------------------------------------------------------------------------

(task {@self get-acquainted ?other}:?get-acquainted
  (tar [k human] @object)
  (lint-waive task-no-preparation)
  (noncompete-set discourse)
  (success-cond (unsubstantial (disclosure-for ?other)))
  (stable-or
    (try
      (when (not (engaged-with ?other)))
      (effects (maintain-proposal {@self hail ?other})))
    (try
      (role @self {@self hail ?other /fail /caused_by ?get-acquainted}:?hail
        (when (hail-turned-down ?other ?hail))
        (effects (set-outcome ?get-acquainted /fail))))
    (try
      (bind (disclosure-for ?other) ?aspect)
      (when (and (engaged-with ?other) (substantial ?aspect)))
      (effects (maintain-proposal {@self tell (msg /utterable [/msg-class tidings] ?aspect) ?other} /quit-trying-on-fail)))))
