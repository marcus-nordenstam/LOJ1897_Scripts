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
;   retire_dwell  : hold the goal, AT the workplace -> a short dwell (giving notice).
;
; Utility 85 beats the work lane (80) so a man who has decided to retire goes to
; give notice rather than putting in another shift; it still loses to night sleep
; (100), so he does it by day.
; ----------------------------------------------------------------------------

(npc-think retire_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self quit_work})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (not (at-workplace ?wp))))
  (utility 85)
  (effects       (begin-goal {@self enter ?wp}))
  (cease-effects (end-goal   {@self enter ?wp})))

(npc-think retire_dwell
  (schedule on-commit)
  (goal {@self quit_work})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (at-workplace ?wp)))
  (utility 85)
  (effects       (begin-goal {@self quit_work}))
  (cease-effects (end-goal   {@self quit_work})))
