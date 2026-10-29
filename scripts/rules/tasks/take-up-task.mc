; ----------------------------------------------------------------------------
; take-up ?partner - @self takes up the hail ?partner called to him from outside any conversation
; @self is in: he gives the response its opening calls for, and the two of them are in one
; conversation (funcs/conversation.mc) - ?partner's when he is in one, @self taking his leave of
; any other, else @self's own, else a new one. It is PREPARATION for converse, proposed by
; engage-hail (drivers/answer-hail-driver.mc). Until he has taken ?partner in the hail still
; stands, so a man who finds something keener first declines it instead (decline-hail). Once in
; it, his presence there is converse (drivers/stay-in-conversation-driver.mc). ?partner's hail
; ended by then leaves nothing to take up, and the take-up fails.
; ----------------------------------------------------------------------------

(task {@self take-up ?partner}:?take-up
  (noncompete-set discourse)
  (tar @excl [k human] @object)
  (preparatory)
  (sequence
    (role ?partner {?partner SAY ? @self /past}
                   {?partner SAY (formulaic ? opening-phrase ?..):?opening @self /past}
      (stage
        (bind (hail-response ?opening) ?response)
        (effects (maintain-proposal {@self tell ?response ?partner})))
      (stage
        (effects
          (bind (conversation-of @self) ?mine)
          (bind (conversation-of ?partner) ?theirs)
          (if (and (substantial ?mine) (substantial ?theirs) (neq ?mine ?theirs))
              (then
                (if (other-party-in ?mine)
                    (then (maintain-proposal {@self take-leave ?mine}))
                    (else (leave-conversation)))))))
      (stage
        (effects
          (if (invited-by ?partner)
              (then
                (bind (cond (case (substantial (conversation-of ?partner)) (conversation-of ?partner))
                            (case (substantial (conversation-of @self)) (conversation-of @self))
                            (else (open-conversation)))
                      ?talk)
                (join-conversation ?talk)
                (bb-public-add-member ?talk participant ?partner)
                (set-outcome ?take-up /succ))
              (else (set-outcome ?take-up /fail))))))))
