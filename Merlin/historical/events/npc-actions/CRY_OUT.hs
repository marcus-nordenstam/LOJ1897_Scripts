; ----------------------------------------------------------------------------
; cry_out (npc-action lane) - the shared ACT body of the EMERGENT confrontation
; (unified think/act model, future_work.md). The think half
; (npc-think/fight.hs) decides; here the 1-minute scream act runs. Every scream
; is a goal that PROMOTES to a shared act body - no begin-act.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self CRY_OUT}
  (duration 1)
  (effects
    (set-attr @self adrenaline 1)
    (set-outcome {@self CRY_OUT} succ)))
