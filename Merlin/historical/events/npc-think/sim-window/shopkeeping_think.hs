; ----------------------------------------------------------------------------
; shopkeeping (npc-think, sim-window) - the clerk resolves to take stock.
;
; A shopkeeper KNOWS his stores: every window he takes on the stocktake
; round (npc-act/shopkeeping.hs takes stock at the counter; this decision owns
; the goal-end). This is how a shelf-adjacent mind's whereabouts beliefs stay
; honest without any ambient disproof: validating the stock IS the job. The sold-vs-stolen
; ledger (a tally document reconciling the day's sales against the gaps)
; is future work - today a gap is simply a gap. The per-cycle desire that
; drives the standing goal to the act lives in npc-think/intra-day/shopkeeping.hs.
; ----------------------------------------------------------------------------

(npc-think plan_stocktake
  (schedule cooldown 1 m)
  (rng-stream behaviour)

  (role @self (grown @self)
              (believes {@self employer ?})
              (believes {@self job [k job shop_clerk]}))

  ; MAINTENANCE: the decision OWNS the stocktake goal end to end. stocktake_act mints no
  ; durable done-belief - it ends the {@self stocktake} act-belief (begun-at-commit /
  ; ended-at-completion), so the completion gate reads that episodic memory: the standing
  ; goal holds until he takes stock, and once stocktake_act resets days-since-last the (when)
  ; drops and the falling edge ends the goal. The monthly timer owns the per-window cadence
  ; (one representative day per window), so the day-threshold need only distinguish "done this
  ; window" (0) from "a window on"; 1 is the minimal such gate. The act never ends the goal.
  (when (>= (days-since-last @self stocktake) 1))

  (effects       (begin-goal {@self stocktake}))
  (cease-effects (end-goal   {@self stocktake})))
