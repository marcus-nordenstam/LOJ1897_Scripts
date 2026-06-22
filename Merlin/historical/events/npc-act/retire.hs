; ----------------------------------------------------------------------------
; retire - the npc-ACT half of the retirement split (Item 5, the great split).
;
; The decision (events/work/employment.hs `retirement`) minted {@self goal
; {@self retire}}. These intra-day events drain it: the worker routes to
; his own workplace and gives notice there, so the retirement happens AT the
; workplace - co-presence his colleagues (and any witness) would see - rather than
; as a faceless world-lane belief edit. The actual (fire) commit fires as the
; act's completion.
;
;   retire_go     : hold the goal, not at the workplace -> travel act to it.
;   retire_dwell  : hold the goal, AT the workplace -> a short dwell (giving notice).
;   retire_commit : the dwell completion (completion-only) - ends employment + clears
;                   the goal.
;
; Utility 85 beats the work lane (80) so a man who has decided to retire goes to
; give notice rather than putting in another shift; it still loses to night sleep
; (100), so he does it by day.
; ----------------------------------------------------------------------------

(hsim-event retire_go
  (intra-day)
  (nl   "@self sets out to give notice")
  (when (and (has-goal quit_work)
             (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (not (self-at ?wp))))
  (utility 85)
  (effects (go @self ?wp)))

(hsim-event retire_dwell
  (intra-day)
  (nl   "@self gives notice at work")
  (when (and (has-goal quit_work)
             (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (self-at ?wp)))
  (utility 85)
  (effects (act retire_commit 60)))

(hsim-event retire_commit
  (schedule (completion-only))
  (nl   "@self retires")
  (effects
    (fire :worker @self)
    (clear-goal @self quit_work)
    (log _retirement @self)))
