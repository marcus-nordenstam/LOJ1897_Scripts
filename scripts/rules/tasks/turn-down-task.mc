; ----------------------------------------------------------------------------
; turn-down ?partner ?msg - @self declines the conversation ?partner opened: he says ?msg, a
; refusal or a retort, once; hearing it, ?partner's hail fails and he leaves what he opened.
; Proposed by decline-hail and rebuff-hail (drivers/answer-hail-driver.mc).
; ----------------------------------------------------------------------------

(task {@self turn-down ?partner ?msg}:?turn-down
  (noncompete-set discourse)
  (tar @excl [k human] @object)
  (aux ?)
  (sequence
    (stage
      (effects (maintain-proposal {@self tell ?msg ?partner})))
    (stage
      (effects
        (set-outcome ?turn-down /succ)))))
