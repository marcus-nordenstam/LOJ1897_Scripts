; ----------------------------------------------------------------------------
; shopkeeping (npc-think, sim-window) - the clerk resolves to take stock.
;
; A shopkeeper KNOWS his stores: every window he takes on the stocktake
; round (npc-act/shopkeeping.hs drains the goal at the counter). This is
; how a shelf-adjacent mind's whereabouts beliefs stay honest without any
; ambient disproof: validating the stock IS the job. The sold-vs-stolen
; ledger (a tally document reconciling the day's sales against the gaps)
; is future work - today a gap is simply a gap. The per-cycle desire that
; drives the standing goal to the act lives in npc-think/intra-day/shopkeeping.hs.
; ----------------------------------------------------------------------------

(npc-think plan_stocktake
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (grown @self)
              (believes {@self employer ?})
              (believes {@self job [k job shop_clerk]}))

  (cont-fire-effects
    (begin-goal {@self stocktake})
    ))
