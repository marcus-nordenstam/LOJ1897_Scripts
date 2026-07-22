; ----------------------------------------------------------------------------
; convey_corpse (npc-action lane) - the deposit ACT of the bereaved-kin lane that
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
; The when-gate REQUIRES being inside a church: without it a convey goal whose
; search sub-goal fatigued out promoted here off-site and filed the body into
; whatever building the bearer stood in. The act-label lives in the cached
; self-role gate, so the promotion scan rejects O(1) before any mind-entry.
(npc-action convey_act
  (act {@self convey ?corpse})
  (duration 15)
  (act-effects
    ; PLACEMENT (not travel): deposit the carried body into a room of this church.
    (place-occupant ?corpse (current-building @self))
    (begin-belief {@self conveyed ?corpse})
    (end-act {@self convey ?corpse})))
; go_act (the shared travel act) lives in npc-act/go.hs.
