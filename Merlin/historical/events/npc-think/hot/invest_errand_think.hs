; ----------------------------------------------------------------------------
; invest_errand - the npc-THINK half of the investment split (approach the firm).
;
; The decision (business_think.hs `investment`) minted {@self goal {@self back <org>}};
; promotion makes the `back` task RUN, and these rungs gate on it. invest_go routes
; the clerk to the org's workplace; AT the firm invest_at_firm seals {@self backed_by
; <org>} and concludes the task - the decision's maintenance then retires the goal.
; ----------------------------------------------------------------------------

(npc-think invest_go
  (task {@self back ?org})
  (when (and (any {?org workplace ?}).target: ?wp
             (not (in-building @self ?wp))))
  (utility 600)
  (effects (maintain-proposal {@self enter ?wp})))

; AT the firm: PROPOSE the backing act (goals never propose themselves). invest_act reads the
; backed org off the standing {@self back} goal focus, so the propose is label-only.
(npc-think invest_at_firm
  (task {@self back ?org})
  (when (and (any {?org workplace ?}).target: ?wp
             (in-building @self ?wp)))
  (utility 600)
  (effects
    (begin-belief {@self backed_by ?org})
    (set-outcome {@self back ?org} succ)))
