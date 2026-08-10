; ----------------------------------------------------------------------------
; choose_kill_method (npc-think). A killer with a standing kill goal and no
; chosen method picks HOW (the kill_method_choice rows): strength-gated,
; weight-scored, money-gated for the commission. The choice mints:
;   {@self method <atom>}            - the MO (rap-sheet / attribution)
;   {@self method_means [k <kind>]}  - the tool requirement; the means seam
;     (intra_day_means_kind_for) reads THIS belief, arming the means
;     acquisition (travel + purchase/steal), which in turn arms the fight
;     lane with the tool.
; commission_killing executes IMMEDIATELY through the (commission-killing)
; conspiracy seam: on a struck contract the instigator's own kill goal ends
; (the hired killer owns it now - his own method, his own hands); a failed
; brokering falls back to bare hands.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think choose_kill_method
  (cooldown 1 m)
  (rng-stream perpetration)

  (role @self 
              (not {@self method ?}))
  (when (> (count-beliefs @self goal) 0))

  (select-joint
    (over-goals ?action ?victim ?goal)
    (table kill_method_choice)
    (bind method ?method)
    (bind means ?means)
    (bind weight ?weight)
    (bind strength_demand ?demand)
    (score (if (= ?action kill)
               (then (* ?weight
                  (if (>= (attr @self strength) ?demand) (then 1) (else 0.3))
                  (if (= ?method commission_killing)
                      (then (if (>= (target-or @self bank_balance 0) 80) (then 1) (else 0)))
                      (else 1))))
               (else 0)))
    (policy roulette))

  (effects
    (debug-print "TRACE_METHOD @self method=?method means=?means victim=?victim")
    (if (= ?method commission_killing)
        (then (if (commission-killing ?victim)
            (then (begin-belief {@self method ?method} /caused_by ?goal)
                (end-goal {@self kill ?victim}))
            ; No connected killer / no reach / no money: fall back to the
            ; bare-handed default so the campaign does not stall.
            (else (begin-belief {@self method strangle} /caused_by ?goal))))
        (else
          (begin-belief {@self method ?method} /caused_by ?goal)
          (if (is-kind ?means)
              (then (begin-belief {@self method_means ?means})))))))
