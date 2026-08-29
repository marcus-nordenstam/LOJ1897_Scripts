
(include "../../../definitions/roles.hs")

(npc-think introduce
  (cooldown 1 m)
  (rng-stream behaviour)

  (role ?stranger 
       (any_human ?stranger)
       (spatial ?stranger co-located @self)
       (not (personally-knows @self ?stranger))
       (not {@self SAY ? ?stranger}))

  ; Sociability gate: an extraverted NPC strikes up an introduction more readily.
  (when (chance (* 0.5 (+ 0.4 (attr @self enthusiasm)))))

  (utility want)

  (effects
    (every {@self (disclosure-tier-labels stranger) ?}): ?facts
    (if ?facts (then (maintain-proposal {@self SAY (utterable-msg ?facts) ?stranger})))))
    