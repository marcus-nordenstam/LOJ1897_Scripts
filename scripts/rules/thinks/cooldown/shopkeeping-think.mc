; ----------------------------------------------------------------------------
; shopkeeping (think) - the clerk resolves to take stock.
;
; A shopkeeper KNOWS his stores: every month he takes on the stocktake
; round (npc-act/shopkeeping.mc takes stock at the counter; this decision owns
; the goal-end). This is how a shelf-adjacent mind's whereabouts beliefs stay
; honest without any ambient disproof: validating the stock IS the job. The sold-vs-stolen
; ledger (a tally document reconciling the day's sales against the gaps)
; is future work - today a gap is simply a gap. The per-cycle desire that
; drives the standing goal to the act lives in thinks/intra-day/shopkeeping.mc.
; ----------------------------------------------------------------------------

; Whoever RUNS a shop takes stock - the PROPRIETOR (seated at founding) as much as a
; hired clerk. Cast on any held job whose org trades from a SHOP building (the
; ?job -> ?org -> ?wp threading is the stocktake-round shape); the store's stock is
; the ONLY source of goods, so the round cannot wait on the labour market hiring clerks.
(think plan-stocktake
  (cooldown 1 m try-until-succ)
  (rng-stream behaviour)

  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?job {@self job ?job}
      (role ?org {?job org ?org}

        ; MAINTENANCE: the decision OWNS the stocktake goal end to end. stocktake_act mints no
        ; durable done-belief - it ends the {@self STOCKTAKE} act-belief (begun-at-commit /
        ; ended-at-completion), so the completion gate reads that episodic memory: the standing
        ; goal holds until he takes stock, and once stocktake_act resets days-since-last the (when)
        ; drops and the falling edge ends the goal. The monthly timer owns the cadence
        ; (one representative day per month), so the day-threshold need only distinguish "done this
        ; month" (0) from "a month on"; 1 is the minimal such gate. The act never ends the goal.
        (role ?wp {?org workplace ?wp}
          (when (and (is-a ?wp [k shop])
                     (>= (days-since-last {@self STOCKTAKE /succ /ever}) 1)))

          (declare-utility duty)
          (effects       (begin-goal {@self STOCKTAKE}))
          (when-unsupported-effects (set-outcome {@self goal {@self STOCKTAKE}} /succ)))))))

; A shop its keeper stands in with no till he knows of gets one: buyers pay into it.
(think plan-open-till
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?job {@self job ?job}
      (role ?org {?job org ?org}
        (role ?wp {?org workplace ?wp} (spatial @self building ?wp)
          (no-role [k pile] {?norole content-kind [k coin]}
                            (spatial ?norole building ?wp)
                            (unknown (spatial ?norole gripped-by)))
          (when (is-a ?wp [k shop]))
          (declare-utility duty)
          (effects (maintain-proposal {@self open-till ?wp})))))))
