; ----------------------------------------------------------------------------
; take-up ?partner - @self takes up the conversation ?partner hailed him into: he gives the
; response its opening calls for, takes his leave of any other conversation he is in, then
; joins ?partner's (funcs/conversation.mc), and the conversation is open. It is PREPARATION for
; converse, proposed by engage-hail (drivers/answer-hail-driver.mc). Until his entry is posted
; the hail still stands, so a man who finds something keener first declines it instead
; (decline-hail). Once posted he hands the conversation over to converse, which nothing can
; stop before it first fires. ?partner gone from every conversation by then - his hail ended
; before it was taken up - leaves nothing to join, and the take-up fails.
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
        (effects
          (bind (conversation-of @self) ?mine)
          (if (and (substantial ?mine) (neq ?mine (conversation-of ?partner)) (other-party-in ?mine))
              (then (maintain-proposal {@self take-leave ?mine})))))
      (stage
        (effects
          (bind (conversation-of ?partner) ?theirs)
          (if (substantial ?theirs)
              (then
                (join-conversation ?theirs)
                (begin-proposal {@self converse ?theirs} /uninterruptable-until-fire)
                (set-outcome ?take-up /succ))
              (else (set-outcome ?take-up /fail))))))))
