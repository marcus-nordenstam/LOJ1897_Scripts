; ----------------------------------------------------------------------------
; hail ?partner - @self calls ?partner into a talk, within call of him, while ?partner stays put. It
; is the same hail at both levels of detail, kept on the boards (funcs/talk.mc): his hailing set
; holds ?partner once it is called, and ?partner's answer comes back in his bbk-hail-answer record of
; him. Unpresented it is called as it begins; presented once he has said the opening - its tell does
; the closing in, as every speaker does - and he hears the answer said. It happens within the talk the two would talk in (talk-between,
; funcs/talk.mc): a talk of his hosts it only when it is that one, so a hail into another talk
; competes with his part in his own, and only by outbidding it takes him out of it
; (tasks/maintain-social-presence-task.mc). Hailing is not joining: only ?partner taking the hail up
; (tasks/take-up-task.mc) brings him into a talk - ?partner's when he is in one, else @self's own,
; else the one he opened for ?partner, else a new one. Nobody hails one who is not hailable, and
; every proposer gates on it: a man in a talk that seats no one more, from one, or one asleep or
; senseless, and a hail he stops being hailable for - another man filling his talk first - fails at
; once. It fails when either talk fills or ?partner sleeps before he answers, or when ?partner turns
; it down. One man's hail stands on ?partner at a time, and on @self (sync, held from its start
; to its end), so two men never hail each other at once. Presented, called to by ?partner before he
; has said his own opening, he lets his hail go and takes ?partner up. It is PREPARATION - an open
; talk is what his part in it needs - so only a driver proposes it. Taken up when ?partner's answer
; accepts it and both are in one talk - also when that is what ends it, its proposer having stopped
; wanting it the instant it was taken up.
; ----------------------------------------------------------------------------

(task {@self hail ?partner}:?hail
  (belief-timeout 15 min)
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
    (bb-public-clear-rec @self bbk-hail-answer ?partner)
    (if (unpresented-lod)
        (then (bb-public-add-member @self hailing ?partner))))
  ; Called out, he waits for the answer however the hail ends: ?partner may be taking him up. Talking
  ; with ?partner already - he took ?partner's own hail up - there is no answer left to wait for, and
  ; none comes from a man out of call or one who cannot hear him (hailable).
  (closing
    (sequence
      (stage
        (when (or (unsubstantial (bb-public-any @self hailing ?partner))
                  (substantial (hail-answer ?partner))
                  (conversing-with ?partner)
                  (not (hailable ?partner))
                  (not (within-call ?partner)))))
      (stage
        (effects (done-closing ?hail)))))
  (cease
    (bb-public-remove-member @self hailing ?partner)
    (if (and (not (conversing-with ?partner)) (hail-accepted ?partner ?hail))
        (then
          (join-talk (talk-of ?partner) ?hail)
          (set-outcome ?hail /succ)))
    (let-go-opened ?partner))
  (and
    ; The tell, (once), is not said again. Said, the hail is called.
    (try
      (lod presented)
      (effects (maintain-proposal {@self tell (formulaic [] opening-phrase greeting) ?partner})))
    (try
      (lod presented)
      (belief {@self tell (formulaic ? opening-phrase ?) ?partner /succ /caused_by ?hail}
        (effects (bb-public-add-member @self hailing ?partner))))
    (try
      (lod presented)
      (belief {@self isa [k human]}
                  -{@self tell (formulaic ? opening-phrase ?) ?partner /succ /caused_by ?hail}
        (role ?partner {?partner SAY ? @self /past /most_recent}
                       {?partner SAY (formulaic ? opening-phrase ?..) @self /past /most_recent}:?opening
          (when (happened-since ?opening ?hail))
          (effects (set-outcome ?hail /fail)))))
    (try
      (lod presented)
      (lint-waive cacheable-read-in-when)
      (belief {@self tell (formulaic ? opening-phrase ?) ?partner /succ /caused_by ?hail}
        (role ?partner {?partner SAY ? @self /past /most_recent}
                       {?partner SAY (formulaic ? opening-phrase ?..) @self /past /most_recent}:?opening
                       -{@self tell ? ?partner /succ /caused_by ?opening}
          (when (and (in-one-talk ?partner @self) (happened-since ?opening ?hail)))
          (effects (maintain-proposal {@self respond ?partner ?opening})))))
    (try
      (lint-waive cacheable-read-in-when)
      (when (hail-accepted ?partner ?hail))
      (effects
        (join-talk (talk-of ?partner) ?hail)
        (set-outcome ?hail /succ)))))
