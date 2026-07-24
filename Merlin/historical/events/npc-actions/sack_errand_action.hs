; ----------------------------------------------------------------------------
; sack_errand (npc-action) - the ACT half of the employer-side job-loss split. The
; go/dwell think half lives in npc-think/sack_errand.hs; this file holds the
; dwell completion that fires the worker and seeds his grudge toward the boss.
; ----------------------------------------------------------------------------

(npc-action {@self sack ?worker}
  (duration 45)
  (effects
    (fire /worker ?worker)
    ; the grudge: the dismissed man resents the boss who let him go (a named motive)
    (nudge-stance ?worker @self warmth -0.5)
    (set-outcome {@self sack} succ)))
