; ----------------------------------------------------------------------------
; take-leave ?partner - @self leaves the conversation he shares with ?partner: he says his
; leave-taking and leaves it (funcs/conversation.mc); the others know by his entry no longer
; naming it.
; ----------------------------------------------------------------------------

(task {@self take-leave ?partner}:?take-leave
  (tar @excl [k human] @object)
  (sequence
    (stage
      (effects (maintain-proposal {@self tell (formulaic [] leave_taking bye) ?partner})))
    (stage
      (effects
        (leave-conversation)
        (set-outcome ?take-leave /succ)))))
