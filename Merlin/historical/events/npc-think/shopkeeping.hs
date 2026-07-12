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

(npc-think plan_stocktake
  (long-term-think)
  (rng-stream behaviour)

  (role @self (grown @self)
              (believes {@self employer ?}))

  (when (believes-obj-kind job [k job shop_clerk]))

  (effects
    (begin-goal {@self stocktake})
    ))

; The per-cycle DESIRE: while the standing stocktake goal holds and the clerk is
; at his counter, push utility 82 onto it so it promotes to stocktake_act. The
; (goal) requirement throttles it to once per window - when stocktake_act ends the
; goal at completion, this stops firing (no re-mint), and plan_stocktake re-seeds
; the goal next window.
(npc-think stocktake_round
  (short-term-think)
  (goal {@self stocktake})
  (when (and (not (under-attack))
             (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (at-workplace ?wp)))
  (utility 82)
  (cont-fire-effects (begin-goal {@self stocktake})))
