; ----------------------------------------------------------------------------
; invest_errand - the npc-ACT half of the investment split (Item 5).
;
; The decision (business.hs `investment`) minted {@self goal {@self back <org>}} on
; the CLERK, where <org> is his own employer (the goal focus). He calls on the firm -
; the workplace he already attends - and the backing is sealed there: {@self backed_by
; <org>}. The destination is the org's `workplace` belief (the same bind work_attendance
; uses), so no telepathy and no address lookup.
;
;   invest_go     : hold the goal, not at the firm -> travel act to its workplace.
;   invest_dwell  : hold the goal, AT the firm -> a short dwell (the proposal).
;   invest_commit : completion (completion-only) - records {@self backed_by <org>}
;                   (the org via goal-focus) + clears the goal.
; ----------------------------------------------------------------------------

(hsim-npc-behaviour invest_go
  (short-term-think)
  (bind (goal-focus back) ?org)
  (when (and (has-goal back)
             (bind {?org workplace ?wp})
             (not (at-place ?wp))))
  (utility 60)
  (effects (begin-act {@self go ?wp})))

(hsim-npc-behaviour invest_dwell
  (short-term-think)
  (bind (goal-focus back) ?org)
  (when (and (has-goal back)
             (bind {?org workplace ?wp})
             (at-place ?wp)))
  (utility 60)
  (effects (begin-act {@self back} 45 invest_commit)))

(hsim-npc-behaviour invest_commit
  (on-completion)
  (effects
    (begin-belief {@self backed_by (goal-focus back)})
    (end-goal {@self back})
    ))
