; ----------------------------------------------------------------------------
; shopkeeping (npc-think, intra-day) - the stocktake counter rung.
;
; The standing stocktake goal is seeded once per window by the sim-window
; plan_stocktake (npc-think/sim-window/shopkeeping.hs). This rung pushes utility
; 82 onto that goal while the clerk stands at his counter so it promotes to
; stocktake_act. A scheduled on-changed rung: it re-selects when the goal is
; (re)committed and, via the movement edge, when the clerk reaches his
; workplace, then re-asserts the goal at 82.
;
; It does NOT own the goal-end. There is no (cease-effects), so the rung is a
; plain scheduled event, not a maintenance hold: it fires the utility bump on an
; edge and deactivates. stocktake_act ends {@self stocktake} at completion,
; which drops this rung's (goal) gate on its own (nothing to cease). Ending the
; goal here as well would double-end it or retract it before the act ran, so the
; end stays where the act owns it. plan_stocktake re-seeds the goal next window.
; ----------------------------------------------------------------------------

(npc-think stocktake_round
  (schedule on-changed)
  (if-blocked hold)
  (goal {@self stocktake})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when  (at-workplace ?wp))
  (utility 82)
  (effects (begin-goal {@self stocktake})))
