; ----------------------------------------------------------------------------
; shopkeeping (npc-think, intra-day) - the per-cycle stocktake desire.
;
; While the standing stocktake goal holds (minted by the sim-window
; plan_stocktake in npc-think/sim-window/shopkeeping.hs) and the clerk is at
; his counter, push utility 82 onto it so it promotes to stocktake_act. The
; (goal) requirement throttles it to once per window - when stocktake_act ends
; the goal at completion, this stops firing (no re-mint), and plan_stocktake
; re-seeds the goal next window.
; ----------------------------------------------------------------------------

(npc-think stocktake_round
  (short-term-think)
  (goal {@self stocktake})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when  (at-workplace ?wp))
  (utility 82)
  (cont-fire-effects (begin-goal {@self stocktake})))
