; introduce - the introduction ACT-BODY (npc-act). The stranger selection and the
; stranger-tier fact enumeration live in npc-think/sim-window/introduce_think.hs;
; this pure act says the chosen self-fact to the stranger. Hearing it files @self as
; the stranger's acquaintance, which is what closes the (personally-knows) dedup.

(npc-act introduce_act
  (act {@self introduce ?stranger ?fact})
  (duration 0)
  (act-effects
    (tell-to ?stranger ?fact)
    (end-act {@self introduce})))
