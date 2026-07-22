; gossip - the gossip ACT-BODY (npc-act). The deliberation (which listener, which
; scandal) lives in npc-think/sim-window/gossip_think.hs; this pure act says the
; chosen fact aloud. Hearing it, ?ear files ?x as an acquaintance, so a scandal
; cascades outward through ?x's widening network. The {@self SAY ...} record the
; tell mints IS the per-listener dedup the think reads.

(npc-act gossip_act
  (act {@self gossip ?ear ?news})
  (duration 0)
  (act-effects
    (tell-to ?ear ?news)
    (end-act {@self gossip})))
