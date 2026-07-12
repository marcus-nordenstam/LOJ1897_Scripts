; ----------------------------------------------------------------------------
; worship (npc-act lane) - the service act of the churchgoing lane. The desire +
; case sub-goal thinks live in npc-think/worship.hs.
;
; The {@self worship} act-belief - begun at commit, ended by (end-act) at completion - IS
; the episodic service memory (interval = the service). days-since-last reads it for the
; pressure; classify_piety reads it (any-tense) for the gist. Locationless like `drink`:
; the church co-presence comes from being AT the church (location), not from the belief.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The service (case A): at a church {@self worship} is the leaf and promotes here. The
; act-belief IS the service memory; ending it closes its interval to the ~90-min service.
(npc-act worship_act
  (when (believes {@self worship}))
  (duration 90)
  (effects (end-act {@self worship})))
; go_act (the shared travel act) lives in npc-act/go.hs.
