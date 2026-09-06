
(include "../../../definitions/roles.mc")

(npc-think introduce
  (cooldown 1 m)
  (rng-stream behaviour)

  (role ?stranger 
       {?stranger isa [k human], condition [k alive]}
       (spatial ?stranger co-located @self)
       (none {@self friend|acquaintance|spouse|lover|mother|father|sibling|child|talk-to ?stranger /ever})
       -{@self SAY ? ?stranger})

  ; Sociability gate: an extraverted NPC strikes up an introduction more readily.
  (when (chance (* 0.5 (+ 0.4 (attr @self enthusiasm)))))

  (utility want)

  (effects
    (every {@self (disclosure-tier-labels stranger) ?}): ?facts
    (if ?facts (then (maintain-proposal {@self SAY (utterable-msg ?facts) ?stranger})))))
    