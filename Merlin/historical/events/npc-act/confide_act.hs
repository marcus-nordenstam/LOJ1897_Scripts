; confide - the private-disclosure ACT-BODY (npc-act). The discloser cast + the
; disclosure roll live in npc-think/sim-window/confide_think.hs; this pure act says
; the calling aloud. The tell-act makes a speech sound at @self's location; the
; post-effects auditory pass delivers + adopts {@self calling ?domain} into every
; co-present listener, sourced to the spoken {@self SAY ...} record.

(npc-act confide_act
  (act {@self confide ?domain})
  (duration 0)
  (act-effects
    (tell {@self calling ?domain})
    (end-act {@self confide})))
