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

(npc-think invest_go
  (short-term-think)
  (goal {@self back})
  (bind (goal-focus back) ?org)
  (when (and (bind {?org workplace ?wp})
             (not (at-workplace ?wp))))
  (utility 60)
  (cont-fire-effects (go-into ?wp)))

; AT the firm: re-affirm the standing back aim with this think's drive so it promotes
; (the go sub-goal spent, the aim is the leaf). begin-goal, not excl-goal - the aim is a
; latched goal, not this node's to auto-retract.
(npc-think invest_dwell
  (short-term-think)
  (goal {@self back})
  (bind (goal-focus back) ?org)
  (when (and (bind {?org workplace ?wp})
             (at-workplace ?wp)))
  (utility 60)
  (cont-fire-effects (begin-goal {@self back})))

; The 45-min proposal, promoted from the back aim at the firm; matched by its (when) on
; the promoted {@self back} belief.
(npc-act invest_act
  (when (believes {@self back}))
  (duration 45)
  (act-effects
    (begin-belief {@self backed_by (goal-focus back)})
    (end-act {@self back})
    (end-goal {@self back})))
