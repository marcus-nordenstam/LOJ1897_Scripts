; table_talk - the mealtime-chatter ACT-BODY (npc-action). The dining gate, the diner
; cast + the untold-fact pick live in npc-think/intra-day/table_talk_think.hs; this
; pure act says the chosen piece of @self's own news to the co-present diner. The
; {@self SAY ...} record the tell mints IS the per-diner dedup the think reads.

(npc-action {@self table_talk ?diner ?belief}
  (duration 0)
  (effects
    (tell-to ?diner ?belief)
    (set-outcome {@self table_talk} succ)))
