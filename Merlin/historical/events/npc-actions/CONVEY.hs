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
; then PERCEIVES {?corpse condition dead} there - no telepathy. The ended
; {@self CONVEY ?corpse} act-belief IS the delivered record (want_convey reads
; it); the deposit fires exactly once per corpse.
; Depositing a corpse already gone (buried elsewhere) is a safe no-op.
; The when-gate REQUIRES being inside a church: without it a convey goal whose
; search sub-goal fatigued out promoted here off-site and filed the body into
; whatever building the bearer stood in. The act-label lives in the cached
; self-role gate, so the promotion scan rejects O(1) before any mind-entry.
(npc-action {@self CONVEY ?corpse}
  (duration 15)
  (effects
    ; PLACEMENT (not travel): deposit the carried body into a room of this church.
    (place-occupant ?corpse (spatial @self building))
    (set-outcome {@self CONVEY ?corpse} succ)))
; go_action (the shared travel act) lives in npc-actions/go_action.hs.
