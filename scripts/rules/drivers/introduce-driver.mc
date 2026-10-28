

(driver introduce
  (cooldown 1 m try-once)
  (rng-stream behaviour)
  (role @self {@self enthusiasm ?enthusiasm}
              {@self (disclosure-tier-labels stranger) ?}
    (role ?stranger 
         {?stranger isa [k human], condition [k alive]}
         (spatial ?stranger co-located @self)
         (none {@self (closeness-labels acquaintance) ?stranger /ever})
         ; A CONCLUDED greeting is what makes him no stranger. Without /succ this reads the
         ; present tense - only a telling still in progress - so each greeting's end made him a
         ; stranger again and the minute cooldown greeted him afresh: 960 greetings in one
         ; afternoon (measured), a body never free for sleep, and the sim down for it.
         -{@self tell ? ?stranger /succ}
         ; One stranger at a time, the nearest: a crowd is met one face after another.
         (select (score (near @self ?stranger)) (policy argmax unknown-last))
  
      ; Sociability gate: an extraverted NPC strikes up an introduction more readily.
      (when (chance (* 0.5 (+ 0.4 ?enthusiasm))))
  
      ; Begun, not maintained: co-presence decides whether he says it, and once begun the line is
      ; said wherever the listener walks - the tell follows him, or fails if it cannot.
      (lint-waive begin-proposal)
      (declare-utility want)
  
      (effects
        (every {@self (disclosure-tier-labels stranger) ?}): ?facts
        (begin-proposal {@self tell (msg /utterable [] ?facts) ?stranger})))))
    