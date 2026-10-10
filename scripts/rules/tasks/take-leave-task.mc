; ----------------------------------------------------------------------------
; take-leave ?partner - @self ends his conversation with ?partner: he says his leave-taking and
; clears both (conversing ..) entries (funcs/conversation.mc), which ends it for both.
; ----------------------------------------------------------------------------

(task {@self take-leave ?partner}:?take-leave
  (tar @excl [k human] @object)
  (sequence
    (stage
      (effects (maintain-proposal {@self tell (formulaic [] leave_taking bye) ?partner})))
    (stage
      (effects
        (end-conversation ?partner)
        (set-outcome ?take-leave /succ)))))
