

(npc-think introduce
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (role ?stranger 
       {?stranger isa [k human], condition [k alive]}
       (spatial ?stranger co-located @self)
       (none {@self (closeness-labels acquaintance) ?stranger /ever})
       ; A CONCLUDED greeting is what makes him no stranger. Without /succ this reads the
       ; present tense - only a SAY still in progress - so each greeting's end made him a
       ; stranger again and the minute cooldown greeted him afresh: 960 greetings in one
       ; afternoon (measured), a body never free for sleep, and the sim down for it.
       -{@self SAY ? ?stranger /succ}

    ; Sociability gate: an extraverted NPC strikes up an introduction more readily.
    (when (chance (* 0.5 (+ 0.4 (target-or @self enthusiasm 0.0)))))

    (utility want)

    (effects
      (every {@self (disclosure-tier-labels stranger) ?}): ?facts
      (if ?facts (then (maintain-proposal {@self SAY (utterable-msg ?facts) ?stranger}))))))
    