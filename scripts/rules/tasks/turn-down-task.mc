; ----------------------------------------------------------------------------
; turn-down ?partner ?msg - @self declines the talk ?partner opened, ?msg a refusal or a retort: his
; answer, turned-down, goes on ?partner's board (answer-hail, funcs/talk.mc), and ?partner's hail
; fails on it. Presented he first says ?msg, once, to the opening it answers. Proposed by
; decline-hail and rebuff-hail (drivers/answer-hail-driver.mc).
; ----------------------------------------------------------------------------

(task {@self turn-down ?partner ?msg}:?turn-down
  (belief-timeout 15 min)
  (category reply)
  (tar @excl [k human] @object)
  (aux ?)
  (and
    (sequence
      (stage
        (when (is-belief (hail-line ?partner @self)))
        (effects
          (bind (as-reply-to ?msg (hail-line ?partner @self)) ?refusal)
          (maintain-intent {@self intent {@self SAY ?refusal ?partner}})))
      (stage
        (effects
          (answer-hail ?partner turned-down)
          (set-hail-state ?partner turned-down)
          (set-outcome ?turn-down /succ))))))
