; ----------------------------------------------------------------------------
; hail ?partner - @self hails ?partner into a talk, within shouting distance of him, while ?partner stays put. It
; is the same hail at both levels of detail (funcs/talk.mc). From its first instant it is made IN
; a talk (hail-into-talk): ?partner's when he is in one, where @self waits for its turn like anyone;
; else @self's own, or a new one he makes, on whose board he puts them both - so whoever speaks to
; ?partner from then finds him in a talk and waits for its turn. He says the opening, closing in on
; ?partner to say it as every speaker does, and the opening said to its end IS the hail: that talk's
; record of ?partner says he is hailed, by @self (bbk-hail, boards/talk.mc). ?partner answers it on
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
; before he has begun his own opening, he lets his hail go and takes ?partner up; hailed by him once
; his own hail stands, each has taken the other up, and neither says a response. It is PREPARATION -
; an open talk is what his part in it needs - so only a driver proposes it. Taken up when ?partner's
; answer accepts it - also when that is what ends it, its proposer having stopped wanting it the
; instant it was taken up. Over without being taken up, it takes off the board whom it put there
; (unseat-hailed).
; ----------------------------------------------------------------------------

(task {@self hail ?partner}:?hail
  (belief-timeout 15 min)
  (category social (scope (talk-between ?partner)))
  (hosts reply)
  (tar @excl [k human] @object)
  (preparatory)
  (preconditions (at-shouting-distance ?partner))
  (failure-cond (or (hail-turned-down ?partner)
                    (not (hailable ?partner))))
  (sync hail @self ?partner)
  (init
    (check (is-a ?partner [k human]))
    (forget-turned-down ?partner)
    (hail-into-talk ?partner))
  ; An opening on his mouth is said to its end, and once it is said he waits for the answer however
  ; the hail ends: ?partner may be taking him up. Let go of before he has begun it, it ends at once.
  ; Talking with ?partner already - he took ?partner's own hail up - there is no answer left to wait
  ; for, and none comes from a man out of shouting distance or one who cannot hear him (hailable).
  (closing
    (sequence
      (stage
        (when (and (not (saying-opening ?partner))
                   (or (neq (hail-state @self ?partner) hailed)
                       (conversing-with ?partner)
                       (not (hailable ?partner))
                       (not (in-shouting-distance ?partner))))))
      (stage
        (effects (done-closing ?hail)))))
  (cease
    (if (and (not (conversing-with ?partner)) (hail-accepted ?partner))
        (then
          (join-talk (talk-of ?partner) ?hail)
          (set-outcome ?hail /succ)))
    (if (hail-turned-down ?partner)
        (then (note-turned-down ?partner)))
    (clear-hail ?partner)
    (unseat-hailed ?partner))
  (and
    ; A hail of his that stands on ?partner is not made again.
    (try
      (when (not (hailing ?partner)))
      (effects (maintain-intent {@self intent {@self SAY (formulaic [] opening-phrase greeting) ?partner}})))
    (try
      (when (and (not (hailing ?partner)) (not (saying-opening ?partner)) (hailed-by ?partner)))
      (effects (set-outcome ?hail /fail)))
    ; Two men who hail each other have each taken the other up.
    (try
      (when (and (hailing ?partner) (hailed-by ?partner)))
      (effects (set-hail-state ?partner taken)))
    (try
      (lint-waive cacheable-read-in-when)
      (when (hail-accepted ?partner))
      (effects
        (join-talk (talk-of ?partner) ?hail)
        (set-outcome ?hail /succ)))))
