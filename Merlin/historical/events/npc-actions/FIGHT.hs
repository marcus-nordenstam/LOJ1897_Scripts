; ----------------------------------------------------------------------------
; fight (npc-action lane) - the shared ACT bodies of the EMERGENT confrontation
; (unified think/act model, future_work.md). The think half
; (npc-think/fight.hs) decides; here the 1-minute strike act runs. Every strike
; is a goal that PROMOTES to a shared act body - no begin-act.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The blow itself (aggressor AND victim): the begun-then-ended {@self FIGHT <foe>}
; act-belief IS one exchange. A fatal result runs the ledger inside (strike-blow)
; and MARKS the victim dead ((alive ?foe) reads false immediately); the full
; death sweep is content - (propagate-death ?foe) right after the fatal blow. A
; non-fatal one leaves a wound and the next deliberation strikes again (while
; the foe lives and is still co-present).
(npc-action {@self FIGHT ?foe}
  (construed_act harm_act wrong_act)  
  (theme violent_to)  
  (duration 1)
  (effects
    (set-attr @self adrenaline 1)
    (strike-blow ?foe kill)
    (if (not (alive ?foe)) (then (debug-print "DTH_FIGHT foe=?foe")))
    (if (not (alive ?foe)) (then (propagate-death ?foe)))
    (set-outcome {@self FIGHT ?foe} succ)))
