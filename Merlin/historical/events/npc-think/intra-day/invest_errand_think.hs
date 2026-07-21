; ----------------------------------------------------------------------------
; invest_errand - the npc-THINK half of the investment split (approach the firm).
;
; The decision (business_think.hs `investment`) minted {@self goal {@self back <org>}}
; and OWNS its whole life (it ceases when invest_act seals {@self backed_by <org>}).
; invest_go routes the clerk to the org's workplace; AT the firm invest_go ceases and
; the goal is the leaf and promotes to invest_act - no dwell rung.
; ----------------------------------------------------------------------------

(npc-think invest_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self back ?org})
  (when (and (believes {?org workplace ?wp})
             (not (at-workplace ?wp))))
  (utility 60)
  (effects       (begin-goal {@self enter ?wp}))
  (cease-effects (end-goal   {@self enter ?wp})))
