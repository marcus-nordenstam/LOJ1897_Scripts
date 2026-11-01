; ----------------------------------------------------------------------------
; take-up ?partner - @self takes up the hail ?partner called to him from outside any conversation
; @self is in: he gives the response its opening calls for, and the two of them are in one
; conversation (take-up-talk, funcs/conversation.mc) - ?partner's when he is in one, else @self's
; own, else a new one. It requires, for as long as it runs, that no talk of his holds him back (clear-to-talk,
; funcs/preconditions.mc), so in another talk than ?partner's he takes his leave of it first. It is
; PREPARATION for converse, proposed by engage-hail (drivers/answer-hail-driver.mc). Until he has
; taken ?partner in the hail still stands, so a man who finds something keener first declines it
; instead (decline-hail). Once in it, his presence there is converse
; (drivers/stay-in-conversation-driver.mc). ?partner's hail ended by then leaves nothing to take up,
; and ?partner's talk full by then has no seat for him: either fails the take-up.
; ----------------------------------------------------------------------------

(task {@self take-up ?partner}:?take-up
  (category reply)
  (tar @excl [k human] @object)
  (preparatory)
  (running-requirements (clear-to-talk ?partner))
  (sequence
    (role ?partner {?partner SAY ? @self /past}
                   {?partner SAY (formulaic ? opening-phrase ?..):?opening @self /past}
      (stage
        (bind (hail-response ?opening) ?response)
        (effects (maintain-proposal {@self tell ?response ?partner})))
      (stage
        (effects
          (bind @nothing ?talk)
          (if (invited-by ?partner)
              (then (bind (take-up-talk ?partner) ?talk)))
          (if (substantial ?talk)
              (then
                (join-conversation ?talk ?take-up)
                (bb-public-add-member ?talk participant ?partner)
                (set-outcome ?take-up /succ))
              (else (set-outcome ?take-up /fail))))))))
