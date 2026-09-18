; ----------------------------------------------------------------------------
; sack_errand (npc-action) - the ACT half of the employer-side job-loss split. The
; go/dwell think half lives in npc-think/sack_errand.hs; this file holds the
; dwell completion that fires the worker and seeds his grudge toward the boss.
; ----------------------------------------------------------------------------

(npc-action {@self SACK ?worker}
  (duration 45)
  (effects
    (strike-from-register ?worker)
    ; the grudge: the dismissed man resents the boss who let him go (a named motive)
    ; TELEPATHY - a rule cannot move ANOTHER mind's stance. Restore this as the other
    ; party's own reflex on the act. Commented out pending that redesign.
    ; (nudge-stance ?worker @self warmth -0.5)
    (set-outcome {@self SACK} /succ)))
