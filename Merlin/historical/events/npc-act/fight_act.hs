; ----------------------------------------------------------------------------
; fight (npc-action lane) - the shared ACT bodies of the EMERGENT confrontation
; (unified think/act model, future_work.md). The think half
; (npc-think/fight.hs) decides; here the 1-minute strike / flee / scream acts run.
; Every strike / flee / scream is a goal that PROMOTES to a shared act body
; (fight_act / flee_act / cry_out_act) - no begin-act.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The blow itself (aggressor AND victim): the begun-then-ended {@self fight <foe>}
; act-belief IS one exchange. A fatal result runs the ledger inside (strike-blow)
; and MARKS the victim dead ((alive ?foe) reads false immediately); the full
; death sweep is content - (propagate-death ?foe) right after the fatal blow. A
; non-fatal one leaves a wound and the next deliberation strikes again (while
; the foe lives and is still co-present).
(npc-action fight_act
  (act {@self fight ?foe})
  (duration 1)
  (act-effects
    (set-attr @self adrenaline 1)
    (strike-blow ?foe kill)
    (if (not (alive ?foe)) (then (debug-print "DTH_FIGHT foe=?foe")))
    (if (not (alive ?foe)) (then (propagate-death ?foe)))
    (end-act {@self fight ?foe})))

(npc-action flee_act
  (act {@self flee ?foe})
  (duration 1)
  (act-effects
    (set-attr @self adrenaline 1)
    (attempt-flee)
    (end-act {@self flee ?foe})))

(npc-action cry_out_act
  (act {@self cry_out})
  (duration 1)
  (act-effects
    (set-attr @self adrenaline 1)
    (end-act {@self cry_out})))
