; ----------------------------------------------------------------------------
; take-up ?partner - @self takes up the hail ?partner called to him from outside any conversation
; @self is in: he gives the response its opening calls for, and the two of them are in one
; conversation (take-up-talk, funcs/conversation.mc) - ?partner's when he is in one, else @self's
; own, else a new one. Entering a conversation is its own category, enter-conversation, within the
; talk the two would talk in (talk-between): a talk of his hosts it only when it is that one, so
; taking up a hail into another talk competes with his part in his own. It is
; PREPARATION for his part in the conversation, proposed by engage-hail (drivers/answer-hail-driver.mc). Until he has
; taken ?partner in the hail still stands, so a man who finds something keener first declines it
; instead (decline-hail). Once in it, his part there is what he says and how he
; leaves (drivers/stay-in-conversation-driver.mc). ?partner's hail ended by then leaves nothing to take up,
; and ?partner's talk full by then has no seat for him: either fails the take-up.
; ----------------------------------------------------------------------------

(task {@self take-up ?partner}:?take-up
  (lod presented)
  (category enter-conversation (scope (talk-between ?partner)))
  (tar @excl [k human] @object)
  (preparatory)
  (sequence
    (role ?partner {?partner SAY ? @self /past /most_recent}
                   {?partner SAY (formulaic ? opening-phrase ?..):?opening @self /past /most_recent}
      (stage
        (bind (hail-response ?opening) ?response)
        (bind (caused-by ?take-up {?partner SAY ? @self /ever}) ?said)
        (effects (maintain-proposal {@self tell ?response ?partner} /caused_by ?said)))
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
