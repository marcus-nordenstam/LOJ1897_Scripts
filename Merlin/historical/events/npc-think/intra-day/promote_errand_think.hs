; ----------------------------------------------------------------------------
; promote_errand (npc-think) - the go/dwell half of the employer-side promotion
; split. The boss holds {@self goal {@self promote_staff <worker>}}; these route
; him to the workplace and dwell to promote the worker. The completion commit
; (promote_staff_act) lives in npc-act/promote_errand.hs.
;
;   promote_go     : hold the goal, not at the workplace -> travel act to it.
;   promote_dwell  : hold the goal, AT the workplace -> a short dwell.
; ----------------------------------------------------------------------------

(npc-think promote_go
  (short-term-think)
  (goal {@self promote_staff})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (not (at-workplace ?wp))))
  (utility 82)
  (cont-fire-effects (go-into ?wp)))

(npc-think promote_dwell
  (short-term-think)
  (goal {@self promote_staff})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (at-workplace ?wp)))
  (utility 82)
  (cont-fire-effects (begin-goal {@self promote_staff})))
