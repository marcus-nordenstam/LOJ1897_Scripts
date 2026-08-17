; ----------------------------------------------------------------------------
; retire (npc-think) - the go/dwell half of the retirement split.
;
; The decision (events/work/employment.hs `retirement`) minted {@self goal
; {@self retire}}. These intra-day events drain it: the worker routes to
; his own workplace and gives notice there, so the retirement happens AT the
; workplace - co-presence his colleagues (and any witness) would see - rather than
; as a faceless world-lane belief edit. The actual (fire) commit fires as the
; act's completion (quit_work_act, npc-act/retire.hs).
;
;   retire_go     : hold the goal, not at the workplace -> travel act to it.
;   retire_dwell  : hold the goal, AT the workplace -> propose giving notice (quit_work_act).
;
; Utility 85 beats the work lane (80) so a man who has decided to retire goes to
; give notice rather than putting in another shift; it still loses to night sleep
; (100), so he does it by day.
; ----------------------------------------------------------------------------

(npc-think retire_go
  (goal {@self QUIT_WORK})
  (role ?job {@self job ?job})
  (role ?org {?job org ?org}           ; produced-restricted: ?org threaded off ?job
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (not (in-building @self ?wp))))
  (effects (maintain-proposal {@self enter ?wp})))

; TERMINAL (act_body_purification): AT the workplace, PROPOSE giving notice - the quit_work act no
; longer promotes off the bare {@self QUIT_WORK} goal (a proposed label drops out of goal
; competition). The ?org role binds ?wp (the workplace) for the arrived gate.
(npc-think retire_dwell
  (goal {@self QUIT_WORK})
  (role ?job {@self job ?job})
  (role ?org {?job org ?org}           ; produced-restricted: ?org threaded off ?job
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (in-building @self ?wp)))
  (effects (maintain-proposal {@self QUIT_WORK})))
