; ----------------------------------------------------------------------------
; promote_errand (npc-think) - the go/dwell half of the boss-side promotion
; split. The boss holds {@self goal {@self PROMOTE_STAFF <worker>}}; these route
; him to the workplace and dwell to promote the worker. The completion commit
; (promote_staff_act) lives in npc-act/promote_errand.hs.
;
;   promote_go     : hold the goal, not at the workplace -> travel act to it.
;   promote_dwell  : hold the goal, AT the workplace -> propose the advancement (promote_staff_act).
; ----------------------------------------------------------------------------

(npc-think promote_go
  (goal {@self PROMOTE_STAFF})
  (role ?job {@self job ?job})
  (role ?org {?job org ?org}           ; produced-restricted: ?org threaded off ?job
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (not (in-building @self ?wp))))
  (utility 820)
  (effects (maintain-proposal {@self enter ?wp})))

; TERMINAL (act_body_purification): AT the workplace, PROPOSE the promotion act - it no longer
; promotes off the bare {@self PROMOTE_STAFF} goal (a proposed label drops out of goal
; competition). The ?org role binds ?wp (the workplace) for the arrived gate.
(npc-think promote_dwell
  (goal {@self PROMOTE_STAFF})
  (role ?job {@self job ?job})
  (role ?org {?job org ?org}           ; produced-restricted: ?org threaded off ?job
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (in-building @self ?wp)))
  (utility 820)
  (effects (maintain-proposal {@self PROMOTE_STAFF})))
