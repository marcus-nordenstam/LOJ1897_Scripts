; ----------------------------------------------------------------------------
; shopkeeping (npc-think, intra-day) - the stocktake terminal-propose rung.
;
; The standing stocktake goal is seeded once per window by the sim-window
; plan_stocktake (npc-think/sim-window/shopkeeping.hs). A dumb {@self stocktake}
; act only runs when a think proposes it; this rung is that think. It PROPOSES
; the stocktake act at drive 82 while the clerk stands at his counter
; (at-workplace), so it competes for his next act and promotes to stocktake_act.
; (schedule always): re-proposes each decision point while he is at the counter.
;
; It does NOT own the goal-end. There is no (cease-effects): the {@self stocktake}
; lifecycle is owned by its minter, the sim-window plan_stocktake, which re-seeds
; the goal each window and ends it once stocktake_act resets days-since-last; this
; rung only re-proposes the act while the clerk stands at his counter.
; ----------------------------------------------------------------------------

(npc-think stocktake_round
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self stocktake})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when  (at-workplace ?wp))
  (utility 82)
  (effects (maintain-proposal {@self stocktake})))
