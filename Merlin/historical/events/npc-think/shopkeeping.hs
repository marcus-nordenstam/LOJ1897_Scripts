; ----------------------------------------------------------------------------
; shopkeeping (npc-think) - the clerk resolves to take stock.
;
; A shopkeeper KNOWS his stores: every window he takes on the stocktake
; round (npc-act/shopkeeping.hs drains the goal at the counter). This is
; how a shelf-adjacent mind's whereabouts beliefs stay honest without any
; ambient disproof: validating the stock IS the job. The sold-vs-stolen
; ledger (a tally document reconciling the day's sales against the gaps)
; is future work - today a gap is simply a gap.
; ----------------------------------------------------------------------------

(hsim-npc-behaviour plan_stocktake
  (long-term-think)
  (rng-stream behaviour)

  (roles
    (role @self (grown @self)
                (believes {@self employer ?})))

  (when (believes-obj-kind job [k job shop_clerk]))

  (effects
    (begin-goal {@self stocktake})
    ))
