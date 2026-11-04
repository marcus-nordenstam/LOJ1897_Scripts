; ----------------------------------------------------------------------------
; hail ?partner - @self calls to ?partner, within call of him, and says the opening - its tell
; does the closing in, as every speaker does, while ?partner stays put. It requires, for as long as
; it runs, that no talk of his holds him back (clear-to-talk, funcs/preconditions.mc): in another
; talk than ?partner's that has room, or in a full one when ?partner is in none, he takes his leave
; of it first. Hailing is not joining: only ?partner taking the hail up (tasks/take-up-task.mc)
; brings him into a conversation - ?partner's when he is in one, else @self's own, else a new one.
; ?partner in a conversation: @self waits from outside it for an opening, its turn, and calls out
; then (turn-board, funcs/conversation.mc). Nobody hails a man in a conversation that seats no one
; more (hailable): it fails when ?partner's talk fills before he answers. Until answered his hail
; stands (hailing). Called to by ?partner before he has called out his own, he lets his hail go and
; takes ?partner up. It is PREPARATION - an open conversation is what his part in it needs - so only a
; driver proposes it. Taken up when ?partner's answer accepts it and both are in one conversation -
; also when that is what ends it, its proposer having stopped wanting it the instant it was taken
; up; turned down when ?partner refuses or rebuffs him, and failed when his opening could not be
; said. A hail is complete only when answered, so when ?partner has hailed him too, each answers
; the other's opening as part of his own hail.
; ----------------------------------------------------------------------------

(task {@self hail ?partner}:?hail
  (category social)
  (hosts reply)
  (tar @excl [k human] @object)
  (preparatory)
  (preconditions (in-call-of ?partner))
  (running-requirements (clear-to-talk ?partner))
  (failure-cond (or (hail-turned-down ?partner ?hail)
                    (not (hailable ?partner))
                    (substantial (any {@self tell (formulaic ? opening-phrase ?) ?partner /fail /caused_by ?hail}))))
  (init
    (check (is-a ?partner [k human]))
    (bb-public-add-member @self hailing ?partner))
  ; Called out, he hears the answer out however the hail ends: ?partner may be taking him up. Talking
  ; with ?partner already - he took ?partner's own hail up - there is no answer left to wait for.
  (closing
    (sequence
      (stage
        (when (or (unsubstantial (any {@self SAY (formulaic ? opening-phrase ?..) ?partner /ever /caused_by ?hail}))
                  (is-belief (hail-reply ?partner ?hail))
                  (engaged-with ?partner)
                  (not (hailable ?partner)))))
      (stage
        (effects (done-closing ?hail)))))
  (cease
    (bb-public-remove-member @self hailing ?partner)
    (if (and (not (engaged-with ?partner)) (hail-accepted ?partner ?hail))
        (then
          (join-conversation (conversation-of ?partner) ?hail)
          (set-outcome ?hail /succ))))
  (and
    (try
      (role @self {@self isa [k human]}
                  -{@self tell (formulaic ? opening-phrase ?) ?partner /past /caused_by ?hail}
        (effects (maintain-proposal {@self tell (formulaic [] opening-phrase greeting) ?partner}))))
    (try
      (role @self {@self isa [k human]}
                  -{@self tell (formulaic ? opening-phrase ?) ?partner /past /caused_by ?hail}
        (role ?partner {?partner SAY ? @self /past /most_recent}
                       {?partner SAY (formulaic ? opening-phrase ?..) @self /past /most_recent}:?opening
          (when (happened-since ?opening ?hail))
          (effects (set-outcome ?hail /fail)))))
    (try
      (lint-waive cacheable-read-in-when)
      (role @self {@self tell (formulaic ? opening-phrase ?) ?partner /past /caused_by ?hail}
        (role ?partner {?partner SAY ? @self /past /most_recent}
                       {?partner SAY (formulaic ? opening-phrase ?..) @self /past /most_recent}:?opening
                       -{@self tell ? ?partner /succ /caused_by ?opening}
          (when (and (conversing-with ?partner @self) (happened-since ?opening ?hail)))
          (effects (maintain-proposal {@self respond ?partner ?opening})))))
    (try
      (lint-waive cacheable-read-in-when)
      (role ?partner {?partner SAY ? @self /past /most_recent}
        (when (hail-accepted ?partner ?hail))
        (effects
          (join-conversation (conversation-of ?partner) ?hail)
          (set-outcome ?hail /succ))))))
