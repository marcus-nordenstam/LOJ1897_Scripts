; ----------------------------------------------------------------------------
; worship (npc-act lane) - the service act of the churchgoing lane. The desire +
; case sub-goal thinks live in npc-think/worship.hs.
;
; The {@self worship} act-belief - begun at commit, ended by (end-act) at completion - IS
; the episodic service memory (interval = the service). days-since-last reads it for the
; pressure; classify_piety reads it (any-tense) for the gist. The when-gate REQUIRES being
; INSIDE a church: the service can only fire on arrival, so the cascade (worship_go /
; worship_find) must actually deliver her there first. Without this gate a bare worship
; goal promotes here off-site and "worships" at home / on the road, falsely resetting
; days-since-last and collapsing the find-a-church search before she ever arrives.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The service (case A): AT a church {@self worship} is the leaf and promotes here. The
; act-belief IS the service memory; ending it closes its interval to the ~90-min service.
(npc-act worship_act
  ; Pure act: worship_at_church guards the (propose) on being in a church, so the body only
  ; extracts its fields off the promoted belief (act_body_purification - precondition on the propose).
  (act {@self worship})
  (duration 90)
  (act-effects
    ; The congregation SEES the service: co-present others mint {her worship her}
    ; (capped fan-out) - the observable-practice evidence observer-side
    ; devoutness folds and abduction read. The record is identical for the
    ; devout and the appearances-keeping pretender, by design. Witnessing is now
    ; engine-side (auto-witness on this obs act at completion), not hand-authored.
    (end-act {@self worship})))
; go_act (the shared travel act) lives in npc-act/go.hs.
