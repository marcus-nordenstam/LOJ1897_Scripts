; confess_fancy - the directed-confession ACT-BODY (npc-action). The pair cast lives in
; npc-think/sim-window/confess_fancy_think.hs; this pure act says it to ?target's
; face: (tell-to ?target {@self fancy ?target}) delivers {@self fancy ?target} into
; ?target's mind, sourced to the spoken {@self SAY ...}, so ?target now KNOWS @self
; fancies them. (tell-to dedupes per-listener and re-asserts on decay.)

(npc-action confess_fancy_act
  (act {@self confess_fancy ?target})
  (duration 0)
  (act-effects
    (tell-to ?target {@self fancy ?target})
    (end-act {@self confess_fancy})))
