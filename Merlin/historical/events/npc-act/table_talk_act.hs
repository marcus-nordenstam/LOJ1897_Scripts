; table_talk - the mealtime-chatter ACT-BODY (npc-act). The dining gate, the diner
; cast + the untold-fact pick live in npc-think/intra-day/table_talk_think.hs; this
; pure act says the chosen piece of @self's own news to the co-present diner. The
; {@self SAY ...} record the tell mints IS the per-diner dedup the think reads.

(npc-act table_talk_act
  (act {@self table_talk ?diner ?belief})
  (duration 0)
  (act-effects
    (tell-to ?diner ?belief)
    (end-act {@self table_talk})))
