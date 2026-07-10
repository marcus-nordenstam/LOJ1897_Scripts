; ----------------------------------------------------------------------------
; choose_kill_method (npc-think). A killer with a standing kill goal and no
; chosen method picks HOW (the kill_method_choice rows): strength-gated,
; weight-scored, money-gated for the commission. The choice mints:
;   {@self method <atom>}            - the MO (rap-sheet / attribution)
;   {@self method_means [k <kind>]}  - the tool requirement; the means seam
;     (intra_day_means_kind_for) reads THIS belief, arming the means_cascade
;     acquisition (travel + purchase/steal), which in turn arms the fight
;     lane with the tool.
; commission_killing executes IMMEDIATELY through the (commission-killing)
; conspiracy seam: on a struck contract the instigator's own kill goal ends
; (the hired killer owns it now - his own method, his own hands); a failed
; brokering falls back to bare hands.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour choose_kill_method
  (long-term-think)
  (rng-stream perpetration)

  (roles
    (role @self (any_human @self)))

  ; Cheap early-out: only goal-holders run the joint reduction; one method
  ; per campaign (re-choice on discharge is future work).
  (when (and (> (count-beliefs @self goal) 0)
             (not (believes {@self method ?}))))

  (select-joint
    (over-goals ?action ?victim ?goal)
    (table kill_method_choice)
    (bind method ?method)
    (bind means ?means)
    (bind weight ?weight)
    (bind strength_demand ?demand)
    (score (if (= ?action kill)
               (* ?weight
                  (if (>= (attr @self strength) ?demand) 1 0.3)
                  (if (= ?method commission_killing)
                      (if (>= (target-or @self bank_balance 0) 80) 1 0)
                      1))
               0))
    (policy weighted))

  (effects
    (if (= ?method commission_killing)
        (if (commission-killing ?victim)
            (do (begin-belief {@self method ?method} /cause ?goal)
                (end-goal {@self kill ?victim}))
            ; No connected killer / no reach / no money: fall back to the
            ; bare-handed default so the campaign does not stall.
            (begin-belief {@self method strangle} /cause ?goal))
        (do
          (begin-belief {@self method ?method} /cause ?goal)
          (if (is-kind ?means)
              (begin-belief {@self method_means ?means}))))))
