; ----------------------------------------------------------------------------
; sack_errand (npc-act) - the ACT half of the employer-side job-loss split. The
; go/dwell think half lives in npc-think/sack_errand.hs; this file holds the
; dwell completion that fires the worker and seeds his grudge toward the boss.
; ----------------------------------------------------------------------------

(npc-act sack_act
  (act {@self sack})
  (duration 45)
  (act-effects
    (fire /worker (goal-focus sack))
    ; the grudge: the dismissed man resents the boss who let him go (a named motive)
    (nudge-stance (goal-focus sack) @self warmth -0.5)
    (end-act  {@self sack})
    (end-goal {@self sack})))
