; ----------------------------------------------------------------------------
; take-leave ?talk [?line] - @self leaves the conversation ?talk: with others in it he says his
; leave-taking to it first - ?line when he gives one, else his goodbye - and alone he simply goes
; (funcs/conversation.mc); the others know by its participant set no longer holding him. He stays
; where he stands until it is said, so what called him away waits for his goodbye. A leave is taken
; only for what outbids the talk: one proposed at less than the talk is worth to him - a hail that
; needs him free of it (clear-to-talk) for something he wants less - fails before a word is said.
; ----------------------------------------------------------------------------

(task {@self take-leave ?talk ?line}:?take-leave
  (category social)
  (hosts reply)
  (tar @excl [k conversation] @object)
  (aux ?)
  (failure-cond (< (utility ?take-leave) (conversation-utility ?talk)))
  (and
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
          (set-outcome ?take-leave /succ))))
    (try (declare-utility fallback)
         (effects (maintain-proposal {@self DWELL (spatial @self space) (+ (time hour) 1)})))))
