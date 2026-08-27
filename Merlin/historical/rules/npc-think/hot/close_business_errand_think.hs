; ----------------------------------------------------------------------------
; close_business_errand (think lane) - the go/dwell think rungs of the
; business-failure split. The winding-up act lives in npc-act/close_business_errand.hs.
;
;   close_go     : hold the goal, not at the premises -> travel sub-goal to it. AT the
;                  premises the go sub-goal is spent, the aim is the leaf and promotes to
;                  close_business_act - no dwell rung (the decision, close_business.hs,
;                  owns the goal's whole life).
;
; Utility 85 matches retirement / founding: a man set on closing pursues it over
; another shift (work lane 80) but still yields to night sleep (100), so he does it
; by day.
; ----------------------------------------------------------------------------

; Not at the premises: pursue a `go` sub-goal to them. articles-building BINDS ?wp
; (the firm's premises building) off ?art, the articles focus bound off the {@self CLOSE_BUSINESS} goal, threading it to the
; at-place gate + the (go) effect.
(npc-think close_go
  (goal {@self CLOSE_BUSINESS ?art})
  (when (and (articles-building ?art ?wp)
             (not (spatial @self building ?wp))))
  (effects (maintain-proposal {@self enter ?wp})))
