
(include "../../../definitions/roles.hs")

; the idea is that if you're too weak to strangle, then shooting or commission are the only options
(define-table kill_method_table
  (fields method              score_weight  score_eval)
  ; strangle task bubbles down to the CHOKE action when copresent with victim
  (record strangle            1             (if (>= (attr @self strength) 0.45) (then 1) (else 0.3)))
  ; shoot task requires getting access to a firearm, then PULL_TRIGGER action when copresent with victim
  (record shoot               0.9           (if (spatial [k firearm] space) (then 1) (else 0.4)))
  ; hire-assassin task requires hiring a killer; the killer will then choose their own killing method
  (record hire-assassin       0.5           (if (>= (target-or @self bank_balance 0) 80) (then 1) (else 0))))

(npc-think choose_kill_method
  (cooldown 1 m)
  (rng-stream perpetration)
  (goal {@self kill ?victim})
  (select-joint
    (table kill_method_table)
    (bind method ?method)
    (bind score_weight ?weight)
    (bind score_eval ?eval)
    (score (* ?weight (eval ?eval)))
    (policy roulette))

  (utility survival)
  (effects
    (debug-print "TRACE_METHOD @self method=?method victim=?victim")
    (maintain-proposal {@self ?method ?victim})))