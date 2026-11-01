; ----------------------------------------------------------------------------
; take-leave ?talk [?line] - @self leaves the conversation ?talk: with others in it he says his
; leave-taking to it first - ?line when he gives one, else his goodbye - and alone he simply goes
; (funcs/conversation.mc); the others know by its participant set no longer holding him.
; ----------------------------------------------------------------------------

(task {@self take-leave ?talk ?line}:?take-leave
  (category social)
  (hosts reply)
  (tar @excl [k conversation] @object)
  (aux ?)
  (sequence
    (stage
      (effects
        (if (other-party-in ?talk)
            (then
              (if (substantial ?line)
                  (then (maintain-proposal {@self tell ?line ?talk}))
                  (else (maintain-proposal {@self tell (formulaic [] leave_taking bye) ?talk})))))))
    (stage
      (effects
        (leave-conversation ?talk)
        (set-outcome ?take-leave /succ)))))
