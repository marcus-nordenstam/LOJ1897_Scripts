
(include "../../../definitions/roles.hs")

(npc-think introduce
  (cooldown 1 m)
  (rng-stream behaviour)

  (role ?stranger 
       (any_human ?stranger)
       {?stranger location (any {@self location}).target}
       (not (personally-knows @self ?stranger))
       (not {@self SAY ? ?stranger}))

  ; Sociability gate: an extraverted NPC strikes up an introduction more readily.
  (when (chance (* 0.5 (+ 0.4 (attr @self enthusiasm)))))

  (utility 18)

  (effects
    (every {@self (disclosure-tier-labels stranger) ?}): ?facts
    (if ?facts (then (maintain-proposal {@self say_to (utterable-msg ?facts) ?stranger})))))
    