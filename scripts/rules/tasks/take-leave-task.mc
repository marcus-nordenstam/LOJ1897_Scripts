; ----------------------------------------------------------------------------
; take-leave ?talk - @self leaves the conversation ?talk: he says his leave-taking to it and
; leaves it (funcs/conversation.mc); the others know by his entry no longer naming it.
; ----------------------------------------------------------------------------

(task {@self take-leave ?talk}:?take-leave
  (tar @excl [k conversation] @object)
  (sequence
    (stage
      (effects (maintain-proposal {@self tell (formulaic [] leave_taking bye) ?talk})))
    (stage
      (effects
        (leave-conversation)
        (set-outcome ?take-leave /succ)))))
