; ----------------------------------------------------------------------------
; promote_errand (npc-think) - the go/dwell half of the employer-side promotion
; split. The boss holds {@self goal {@self promote_staff <worker>}}; these route
; him to the workplace and dwell to promote the worker. The completion commit
; (promote_staff_act) lives in npc-act/promote_errand.hs.
;
;   promote_go     : hold the goal, not at the workplace -> travel act to it.
;   promote_dwell  : hold the goal, AT the workplace -> propose the advancement (promote_staff_act).
; ----------------------------------------------------------------------------

(npc-think promote_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self promote_staff})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (not (at-workplace ?wp))))
  (utility 82)
  (effects       (begin-goal {@self enter ?wp}))
  (cease-effects (end-goal   {@self enter ?wp})))

; TERMINAL (act_body_purification): AT the workplace, PROPOSE the promotion act - it no longer
; promotes off the bare {@self promote_staff} goal (a proposed label drops out of goal
; competition). Reactive (schedule always): re-proposes each decision point while the goal stands
; + the boss is at his workplace. The ?org role binds ?wp (the workplace) for the arrived gate.
(npc-think promote_dwell
  (schedule always)
  (goal {@self promote_staff})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (at-workplace ?wp)))
  (utility 82)
  (effects (maintain-proposal {@self promote_staff})))
