; ----------------------------------------------------------------------------
; hail ?partner - @self calls to ?partner, within call of him, and says the opening - its tell does
; the closing in, as every speaker does, while ?partner stays put. It happens within the talk the two
; would talk in (talk-between, funcs/conversation.mc): a talk of his hosts it only when it is that
; one, so a hail into another talk competes with his part in his own, and only by outbidding it
; takes him out of it (tasks/maintain-social-presence-task.mc). Hailing is not joining: only
; ?partner taking the hail up (tasks/take-up-task.mc) brings him into a conversation - ?partner's
; when he is in one, else @self's own, else a new one.
; ?partner in a conversation: @self waits from outside it for an opening, its turn, and calls out
; then (turn-board, funcs/conversation.mc). Nobody hails one who is not hailable, and every proposer
; gates on it: a man in a conversation that seats no one more, from one, or one asleep or senseless.
; It fails when either talk fills or ?partner sleeps before he answers. One man's hail stands on
; ?partner at a time (sync, held from its start to its end), and only that one is his (hailing): the
; rest stay proposals until their turn, so a crowd that all want him at once never stands on him at
; once. Called to by ?partner before he has called out his own, he lets his hail go and takes
; ?partner up. It is PREPARATION - an open
; conversation is what his part in it needs - so only a driver proposes it. Taken up when
; ?partner's answer accepts it and both are in one conversation - also when that is what ends it,
; its proposer having stopped wanting it the instant it was taken up; turned down when ?partner
; refuses or rebuffs him, and failed when his opening could not be said. A hail is complete only
; when answered, so when ?partner has hailed him too, each answers the other's opening as part of
; his own hail.
; ----------------------------------------------------------------------------

(task {@self hail ?partner}:?hail
  (lod presented)
  (category social (scope (talk-between ?partner)))
  (hosts reply)
  (tar @excl [k human] @object)
  (preparatory)
  (preconditions (in-call-of ?partner))
  (failure-cond (or (hail-turned-down ?partner ?hail)
                    (not (hailable ?partner))))
  (sync hail @self ?partner)
  (init
    (check (is-a ?partner [k human]))
    (check (hailable ?partner))
    (bb-public-add-member @self hailing ?partner))
  ; Called out, he hears the answer out however the hail ends: ?partner may be taking him up. Talking
  ; with ?partner already - he took ?partner's own hail up - there is no answer left to wait for, and
  ; none comes from a man out of call or one who cannot hear him (hailable).
  (closing
    (sequence
      (stage
        (when (or (unsubstantial (any {@self SAY (formulaic ? opening-phrase ?..) ?partner /ever /caused_by ?hail}))
                  (is-belief (hail-reply ?partner ?hail))
                  (conversing-with ?partner)
                  (not (hailable ?partner))
                  (not (within-call ?partner)))))
      (stage
        (effects (done-closing ?hail)))))
  (cease
    (bb-public-remove-member @self hailing ?partner)
    (if (and (not (conversing-with ?partner)) (hail-accepted ?partner ?hail))
        (then
          (join-conversation (conversation-of ?partner) ?hail)
          (set-outcome ?hail /succ))))
  (and
    ; The tell, (once), is not said again.
    (try
      (effects (maintain-proposal {@self tell (formulaic [] opening-phrase greeting) ?partner})))
    (try
      (belief {@self isa [k human]}
                  -{@self tell (formulaic ? opening-phrase ?) ?partner /succ /caused_by ?hail}
        (role ?partner {?partner SAY ? @self /past /most_recent}
                       {?partner SAY (formulaic ? opening-phrase ?..) @self /past /most_recent}:?opening
          (when (happened-since ?opening ?hail))
          (effects (set-outcome ?hail /fail)))))
    (try
      (lint-waive cacheable-read-in-when)
      (belief {@self tell (formulaic ? opening-phrase ?) ?partner /succ /caused_by ?hail}
        (role ?partner {?partner SAY ? @self /past /most_recent}
                       {?partner SAY (formulaic ? opening-phrase ?..) @self /past /most_recent}:?opening
                       -{@self tell ? ?partner /succ /caused_by ?opening}
          (when (and (in-one-conversation ?partner @self) (happened-since ?opening ?hail)))
          (effects (maintain-proposal {@self respond ?partner ?opening})))))
    (try
      (lint-waive cacheable-read-in-when)
      (role ?partner {?partner SAY ? @self /past /most_recent}
        (when (hail-accepted ?partner ?hail))
        (effects
          (join-conversation (conversation-of ?partner) ?hail)
          (set-outcome ?hail /succ))))))
