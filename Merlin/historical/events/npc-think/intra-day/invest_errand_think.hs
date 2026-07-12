; ----------------------------------------------------------------------------
; invest_errand - the npc-THINK half of the investment split (approach the firm).
; The clerk holds {@self back <org>}: travel to the org's workplace, then dwell
; there to promote the proposal.
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
