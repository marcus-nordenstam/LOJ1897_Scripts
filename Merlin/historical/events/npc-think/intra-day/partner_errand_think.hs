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
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self partner})
  (when (and (articles-building (goal-focus partner) ?venue)
             (not (in-building ?venue))))
  (utility 85)
  (effects (maintain-proposal {@self enter ?venue})))

; AT the premises: PROPOSE the partnership act (goals never propose themselves). partner_act reads
; the firm articles off the standing {@self partner} goal focus, so the propose is label-only.
(npc-think partner_at_firm
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self partner})
  (when (and (articles-building (goal-focus partner) ?venue)
             (in-building ?venue)))
  (utility 85)
  (effects (maintain-proposal {@self partner})))
