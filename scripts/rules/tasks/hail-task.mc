; ----------------------------------------------------------------------------
; hail ?partner - @self calls ?partner into a talk, within call of him, while ?partner stays put. It
; is the same hail at both levels of detail (funcs/talk.mc). From its first instant it is called IN
; a talk (call-into-talk): ?partner's when he is in one, where @self waits for its turn like anyone;
; else @self's own, or a new one he makes, on whose board he puts them both - so whoever speaks to
; ?partner from then finds him in a talk and waits for its turn. He says the opening, closing in on
; ?partner to say it as every speaker does, and the opening said to its end IS the call: that talk's
; record of ?partner says he is called, by @self (bbk-hail, boards/talk.mc). ?partner answers it on
; that record, taken or turned-down, and @self clears it when his hail is over. It happens within the
; talk the two would talk in (talk-between, funcs/talk.mc): a talk of his hosts it only when it is
; that one, so a hail into another talk competes with his part in his own, and only by outbidding it
; takes him out of it (tasks/maintain-social-presence-task.mc). Being on the talk's board is not
; holding a part in it: ?partner holds his once he takes the hail up (tasks/take-up-task.mc), @self
; his once it is taken up. Nobody hails one who is not hailable, and every proposer gates on it: a
; man in a talk that seats no one more, from one, or one asleep or senseless, and a hail he stops
; being hailable for - another man filling his talk first - fails at once. It fails when either talk
; fills or ?partner sleeps before he answers, or when ?partner turns it down. One man's hail stands
; on ?partner at a time, and on @self (sync, held from its start to its end). Called by ?partner
; before he has begun his own opening, he lets his hail go and takes ?partner up; called by him once
; his own call stands, each has taken the other up, and neither says a response. It is PREPARATION -
; an open talk is what his part in it needs - so only a driver proposes it. Taken up when ?partner's
; answer accepts it - also when that is what ends it, its proposer having stopped wanting it the
; instant it was taken up. Over without being taken up, it takes off the board whom it put there
; (uncall).
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
    (call-into-talk ?partner))
  ; An opening on his mouth is said to its end, and once it is said he waits for the answer however
  ; the hail ends: ?partner may be taking him up. Let go of before he has begun it, it ends at once.
  ; Talking with ?partner already - he took ?partner's own hail up - there is no answer left to wait
  ; for, and none comes from a man out of call or one who cannot hear him (hailable).
  (closing
    (sequence
      (stage
        (when (and (not (saying-opening ?partner))
                   (or (neq (hail-state @self ?partner) called)
                       (conversing-with ?partner)
                       (not (hailable ?partner))
                       (not (within-call ?partner))))))
      (stage
        (effects (done-closing ?hail)))))
  (cease
    (if (and (not (conversing-with ?partner)) (hail-accepted ?partner ?hail))
        (then
          (join-talk (talk-of ?partner) ?hail)
          (set-outcome ?hail /succ)))
    (clear-hail ?partner)
    (uncall ?partner))
  (and
    ; A call of his that stands on ?partner is not called again.
    (try
      (when (not (calling ?partner)))
      (effects (maintain-intent {@self intent {@self SAY (formulaic [] opening-phrase greeting) ?partner}})))
    (try
      (when (and (not (calling ?partner)) (not (saying-opening ?partner)) (called-by ?partner)))
      (effects (set-outcome ?hail /fail)))
    ; Two men who call each other have each taken the other up.
    (try
      (when (and (calling ?partner) (called-by ?partner)))
      (effects
        (set-hail-state ?partner taken)
        (answer-hail ?partner taken)))
    (try
      (lint-waive cacheable-read-in-when)
      (when (hail-accepted ?partner ?hail))
      (effects
        (join-talk (talk-of ?partner) ?hail)
        (set-outcome ?hail /succ)))))
