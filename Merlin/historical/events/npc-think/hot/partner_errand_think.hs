; ----------------------------------------------------------------------------
; partner_errand - the npc-THINK half of the business-partnership split (approach).
;
; The decision (business_think.hs `business_partnership`) minted {@self goal {@self
; partner <articles>}} and OWNS its whole life (it ceases when partner_act seats the
; clerk as proprietor/org_head). partner_go routes him to the firm's premises; AT the
; premises partner_go ceases and the goal is the leaf and promotes to partner_act -
; no dwell rung.
; ----------------------------------------------------------------------------

(npc-think partner_go
  (goal {@self PARTNER ?art})
  (when (and (articles-building ?art ?venue)
             (not (in-building @self ?venue))))
  (utility 85)
  (effects (maintain-proposal {@self enter ?venue})))

; AT the premises: PROPOSE the partnership act (goals never propose themselves). partner_act reads
; the firm articles off the standing {@self PARTNER} goal focus, so the propose is label-only.
(npc-think partner_at_firm
  (goal {@self PARTNER ?art})
  (when (and (articles-building ?art ?venue)
             (in-building @self ?venue)))
  (utility 85)
  (effects (maintain-proposal {@self PARTNER})))
