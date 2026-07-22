; ----------------------------------------------------------------------------
; invest_errand - the npc-ACT half of the investment split (Item 5).
;
; The decision (business.hs `investment`) minted {@self goal {@self back <org>}} on
; the CLERK, where <org> is his own employer (the goal focus). He calls on the firm -
; the workplace he already attends - and the backing is sealed there: {@self backed_by
; <org>}. The destination is the org's `workplace` belief (the same bind work_attendance
; uses), so no telepathy and no address lookup.
;
;   invest_go     : hold the aim, not at the firm -> travel sub-goal to its workplace.
;   invest_dwell  : hold the aim, AT the firm -> feed the aim this think's drive so it
;                   PROMOTES (the proposal).
;   invest_act    : the promoted 45-min proposal - records {@self backed_by <org>} (the
;                   org via goal-focus) + ends the act + the aim.
; ----------------------------------------------------------------------------

; The 45-min proposal, promoted from the back aim at the firm; matched by its (when) on
; the promoted {@self back} belief.
(npc-action invest_act
  (act {@self back})
  (duration 45)
  (act-effects
    (begin-belief {@self backed_by (goal-focus back)})
    (end-act {@self back})))
