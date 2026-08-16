; ----------------------------------------------------------------------------
; flee (npc-action lane) - the shared ACT body of the EMERGENT confrontation
; (unified think/act model, future_work.md). The think half
; (npc-think/fight.hs) decides; here the 1-minute flee act runs. Every flee is
; a goal that PROMOTES to a shared act body - no begin-act.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self FLEE ?foe}
  (duration 1)
  (effects
    (set-attr @self adrenaline 1)
    (attempt-flee)
    (set-outcome {@self FLEE ?foe} succ)))
