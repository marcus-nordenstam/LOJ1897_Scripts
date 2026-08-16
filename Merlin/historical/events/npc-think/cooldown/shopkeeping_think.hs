; ----------------------------------------------------------------------------
; shopkeeping (npc-think) - the clerk resolves to take stock.
;
; A shopkeeper KNOWS his stores: every month he takes on the stocktake
; round (npc-act/shopkeeping.hs takes stock at the counter; this decision owns
; the goal-end). This is how a shelf-adjacent mind's whereabouts beliefs stay
; honest without any ambient disproof: validating the stock IS the job. The sold-vs-stolen
; ledger (a tally document reconciling the day's sales against the gaps)
; is future work - today a gap is simply a gap. The per-cycle desire that
; drives the standing goal to the act lives in npc-think/intra-day/shopkeeping.hs.
; ----------------------------------------------------------------------------

; Whoever RUNS a shop takes stock - the PROPRIETOR (seated at founding) as much as a
; hired clerk. Cast on any held job whose org trades from a SHOP building (the
; ?job -> ?org -> ?wp threading is the stocktake_round shape); the store's stock is
; the ONLY source of goods, so the round cannot wait on the labour market hiring clerks.
(npc-think plan_stocktake
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self (grown @self))
  (role ?job {@self job ?job})
  (role ?org {?job org ?org})

  ; MAINTENANCE: the decision OWNS the stocktake goal end to end. stocktake_act mints no
  ; durable done-belief - it ends the {@self STOCKTAKE} act-belief (begun-at-commit /
  ; ended-at-completion), so the completion gate reads that episodic memory: the standing
  ; goal holds until he takes stock, and once stocktake_act resets days-since-last the (when)
  ; drops and the falling edge ends the goal. The monthly timer owns the cadence
  ; (one representative day per month), so the day-threshold need only distinguish "done this
  ; month" (0) from "a month on"; 1 is the minimal such gate. The act never ends the goal.
  (when (and (any {?org workplace ?}).target: ?wp
             (is-a ?wp [k building shop])
             (>= (days-since-last {@self STOCKTAKE /ever}) 1)))

  (utility duty 100)
  (effects       (begin-goal {@self STOCKTAKE}))
  (cease-effects (end-goal   {@self STOCKTAKE})))
