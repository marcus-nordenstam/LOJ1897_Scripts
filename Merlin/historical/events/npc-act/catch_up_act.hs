; catch_up - the self-news ACT-BODY (npc-action). The listener cast + the untold-fact
; pick live in npc-think/sim-window/catch_up_think.hs; this pure act says the chosen
; piece of @self's own news to the co-present guest. The {@self SAY ...} record the
; tell mints IS the per-guest dedup the think reads.

(npc-action catch_up_act
  (act {@self catch_up ?guest ?belief})
  (duration 0)
  (act-effects
    (tell-to ?guest ?belief)
    (set-outcome {@self catch_up} succ)))
