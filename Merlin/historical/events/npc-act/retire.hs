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

(hsim-npc-behaviour retire_go
  (short-term-think)
  (when (and (has-goal quit_work)
             (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (not (at-place ?wp))))
  (utility 85)
  (effects (go @self ?wp)))

(hsim-npc-behaviour retire_dwell
  (short-term-think)
  (when (and (has-goal quit_work)
             (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (at-place ?wp)))
  (utility 85)
  (effects (act retire_commit 60)))

(hsim-npc-behaviour retire_commit
  (on-completion)
  (effects
    (fire /worker @self)
    (end-goal {@self quit_work})
    ))
