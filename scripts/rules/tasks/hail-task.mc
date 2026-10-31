; ----------------------------------------------------------------------------
; hail ?partner - @self calls to ?partner, within call of him, and says the opening - its tell
; does the closing in, as every speaker does, while ?partner stays put. It requires, for as long as
; it runs, that no talk of his holds him back (clear-to-talk, funcs/preconditions.mc): in another talk than ?partner's
; that has room, or in a full one when ?partner is in none, he takes his leave of it first. ?partner
; in a conversation with room: @self joins it with his hail, his opening bids for its floor, and
; ?partner answers it as he answers any line said to him there. A talk that seats no one more
; (conversation-full) he does not join: he calls from where he is, and ?partner turns him down.
; ?partner in none: there is no conversation until ?partner takes the hail up
; (tasks/take-up-task.mc), which makes one - @self's own when he is in one - and takes him into
; it; until then his hail stands (hailing, funcs/conversation.mc). Called to by ?partner before he
; has called out his own, he lets his hail go and takes ?partner up. It is PREPARATION - an open
; conversation is what converse assumes - so only a driver proposes it. Taken up when ?partner's
; answer accepts it and both are in one conversation - also when that is what ends it, its
; proposer having stopped wanting it the instant it was taken up; turned down when ?partner
; refuses or rebuffs him, and failed when his opening could not be said. A hail is complete only
; when answered, so when ?partner has hailed him too, each answers the other's opening as part of
; his own hail. Ended any other way, he leaves ?partner's conversation if his hail took him into it.
; ----------------------------------------------------------------------------

(task {@self hail ?partner}:?hail
  (noncompete-set discourse)
  (tar @excl [k human] @object)
  (preparatory)
  (running-requirements (clear-to-talk ?partner))
  (failure-cond (or (hail-turned-down ?partner ?hail)
                    (substantial (any {@self tell (formulaic ? opening-phrase ?) ?partner /fail /caused_by ?hail}))))
  (init
    (check (is-a ?partner [k human]))
    (bb-public-add-member @self hailing ?partner))
  (cease
    (bb-public-remove-member @self hailing ?partner)
    (if (not (engaged-with ?partner))
        (then
          (cond (case (hail-accepted ?partner ?hail)
                  (join-conversation (conversation-of ?partner))
                  (set-outcome ?hail /succ))
                (case (conversing-with ?partner @self) (leave-conversation (conversation-of ?partner)))))))
  (and
    (try
      (role @self {@self isa [k human]}
                  -{@self tell (formulaic ? opening-phrase ?) ?partner /past /caused_by ?hail}
        (effects
          (bind (conversation-of ?partner) ?theirs)
          (if (and (substantial ?theirs) (not (conversation-full ?theirs)))
              (then (join-conversation ?theirs)))
          (maintain-proposal {@self tell (formulaic [] opening-phrase greeting) ?partner}))))
    (try
      (role @self {@self isa [k human]}
                  -{@self tell (formulaic ? opening-phrase ?) ?partner /past /caused_by ?hail}
        (role ?partner {?partner SAY ? @self /past}
                       {?partner SAY (formulaic ? opening-phrase ?..) @self /past}:?opening
          (when (happened-since ?opening ?hail))
          (effects (set-outcome ?hail /fail)))))
    (try
      (lint-waive cacheable-read-in-when)
      (role @self {@self tell (formulaic ? opening-phrase ?) ?partner /past /caused_by ?hail}
        (role ?partner {?partner SAY ? @self /past}
                       {?partner SAY (formulaic ? opening-phrase ?..) @self /past}:?opening
                       -{@self tell ? ?partner /succ /caused_by ?opening}
          (when (and (conversing-with ?partner @self) (happened-since ?opening ?hail)))
          (effects (maintain-proposal {@self respond ?partner ?opening})))))
    (try
      (lint-waive cacheable-read-in-when)
      (role ?partner {?partner SAY ? @self /past}
        (when (hail-accepted ?partner ?hail))
        (effects
          (join-conversation (conversation-of ?partner))
          (set-outcome ?hail /succ))))))
