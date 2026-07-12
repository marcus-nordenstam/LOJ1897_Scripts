; ----------------------------------------------------------------------------
; close_business_errand (think lane) - the go/dwell think rungs of the
; business-failure split. The winding-up act lives in npc-act/close_business_errand.hs.
;
;   close_go     : hold the goal, not at the premises -> travel sub-goal to it.
;   close_dwell  : hold the goal, AT the premises -> re-affirm the aim so it promotes.
;
; Utility 85 matches retirement / founding: a man set on closing pursues it over
; another shift (work lane 80) but still yields to night sleep (100), so he does it
; by day.
; ----------------------------------------------------------------------------

; Not at the premises: pursue a `go` sub-goal to them. articles-building BINDS ?wp
; (the firm's premises building) off the goal-focus articles, threading it to the
; at-place gate + the (go) effect.
(npc-think close_go
  (short-term-think)
  (goal {@self close_business})
  (when (and (articles-building (goal-focus close_business) ?wp)
             (not (at-workplace ?wp))))
  (utility 85)
  (cont-fire-effects (go-into ?wp)))

; AT the premises: re-affirm the standing aim with this think's utility so, the go
; sub-goal spent, the aim is the leaf and promotes to close_business_act.
(npc-think close_dwell
  (short-term-think)
  (goal {@self close_business})
  (when (and (articles-building (goal-focus close_business) ?wp)
             (at-workplace ?wp)))
  (utility 85)
  (cont-fire-effects (begin-goal {@self close_business})))
