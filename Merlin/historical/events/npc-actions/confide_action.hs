; confide - the private-disclosure ACT-BODY (npc-action). The discloser cast + the
; disclosure roll live in npc-think/sim-window/confide_think.hs; this pure act says
; the calling aloud. The tell-act makes a speech sound at @self's location; the
; post-effects auditory pass delivers + adopts {@self calling ?domain} into every
; co-present listener, sourced to the spoken {@self SAY ...} record.

(npc-action {@self confide ?domain}
  (duration 0)
  (effects
    (tell {@self calling ?domain})
    (set-outcome {@self confide} succ)))
