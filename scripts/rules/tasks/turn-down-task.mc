; ----------------------------------------------------------------------------
; turn-down ?partner ?msg - @self declines the conversation ?partner opened: he says ?msg, a
; refusal or a retort, once, and then ends the conversation for both (funcs/conversation.mc).
; Proposed by decline-hail and rebuff-hail (thinks/hot/answer-hail-think.mc).
; ----------------------------------------------------------------------------

(task {@self turn-down ?partner ?msg}:?turn-down
  (tar @excl [k human] @object)
  (aux ?)
  (sequence
    (stage
      (effects (maintain-proposal {@self tell ?msg ?partner})))
    (stage
      (effects
        (end-conversation ?partner)
        (set-outcome ?turn-down /succ)))))
