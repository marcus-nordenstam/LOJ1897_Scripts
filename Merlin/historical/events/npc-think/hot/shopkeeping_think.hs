; ----------------------------------------------------------------------------
; shopkeeping (npc-think, intra-day) - the stocktake terminal-propose rung.
;
; The standing stocktake goal is seeded monthly by the plan_stocktake decision
; (npc-think/cooldown/shopkeeping.hs). A dumb {@self stocktake}
; act only runs when a think proposes it; this rung is that think. It PROPOSES
; the stocktake act at drive 82 while the clerk stands at his counter
; (at-workplace), so it competes for his next act and promotes to stocktake_act.
;
; It does NOT own the goal-end. There is no (cease-effects): the {@self stocktake}
; lifecycle is owned by its minter, the monthly plan_stocktake, which re-seeds
; the goal each month and ends it once stocktake_act resets days-since-last; this
; rung only re-proposes the act while the clerk stands at his counter.
; ----------------------------------------------------------------------------

(npc-think stocktake_round
  (goal {@self stocktake})
  (role ?job {@self job ?job})
  (role ?org {?job org ?org}           ; produced-restricted: ?org threaded off ?job
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when  (in-building @self ?wp))
  (utility 82)
  (effects (maintain-proposal {@self stocktake})))
