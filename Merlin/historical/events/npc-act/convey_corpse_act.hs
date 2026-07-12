; ----------------------------------------------------------------------------
; convey_corpse (npc-act lane) - the deposit ACT of the bereaved-kin lane that
; CARRIES a dead relative's body to a church. The think half
; (npc-think/convey_corpse.hs) routes the bearer; here the body is filed into the
; church's room where a co-present priest PERCEIVES it (bury.hs) - no telepathy.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; CASE A (deposit): at a church the convey goal is the leaf and promotes here.
; (relocate ?corpse <church>) files the body into the church's room contents (the
; env placement seam derives its {?corpse location <room>}); a co-present priest
; then PERCEIVES {?corpse condition dead} there - no telepathy. The one-shot
; marker bars re-carting; ending the act-belief makes the deposit fire exactly
; once. Depositing a corpse already gone (buried elsewhere) is a safe no-op.
(npc-act convey_act
  (when (believes {@self convey ?corpse}))
  (duration 15)
  (act-effects
    (relocate ?corpse (current-building @self))
    (begin-belief {@self conveyed ?corpse})
    (end-act {@self convey ?corpse})))
; go_act (the shared travel act) lives in npc-act/go.hs.
