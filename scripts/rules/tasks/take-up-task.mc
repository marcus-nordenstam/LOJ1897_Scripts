; ----------------------------------------------------------------------------
; take-up ?partner - @self takes up the conversation ?partner hailed him into: he gives the
; response its opening calls for, takes his leave of any other conversation he is in, then
; joins ?partner's (funcs/conversation.mc), and the conversation is open. It is PREPARATION for
; converse, proposed by engage-hail (drivers/answer-hail-driver.mc). Until his entry is posted
; the hail still stands, so a man who finds something keener first declines it instead
; (decline-hail). Once posted he hands the conversation over to converse, which nothing can
; stop before it first fires.
; ----------------------------------------------------------------------------

(task {@self take-up ?partner}:?take-up
  (tar @excl [k human] @object)
  (preparatory)
  ; Converse must start once take-up is done, which only a begun proposal outlives take-up for.
  (lint-waive begin-proposal)
  (sequence
    (role ?partner {?partner SAY ? @self /past}
                   {?partner SAY (formulaic ? opening-phrase ?..):?opening @self /past}
      (stage
        (bind (hail-response ?opening) ?response)
        (effects (maintain-proposal {@self tell ?response ?partner})))
      (stage
        (bind (conversation-of @self) ?mine)
        (effects
          (if (and (substantial ?mine) (neq ?mine (conversation-of ?partner)))
              (then
                (for-each ?party (every {?mine participant ?})
                  (bind ?party.target ?who)
                  (if (and (neq ?who @self) (in-conversation ?who ?mine))
                      (then (maintain-proposal {@self take-leave ?who}) (break))))))))
      (stage
        (effects
          (join-conversation (conversation-of ?partner))
          (begin-proposal {@self converse ?partner} /uninterruptable-until-fire)
          (set-outcome ?take-up /succ))))))
