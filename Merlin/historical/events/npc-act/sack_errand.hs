; ----------------------------------------------------------------------------
; sack_errand - the npc-ACT half of the employer-side job-loss split (Item 5).
;
; The decision (employment.hs `job_loss`) minted {@self goal {@self sack
; <worker>}} on the BOSS (the org-head). The boss goes to the workplace and lets
; the man go in person - and the sacked man's grudge toward the NAMED boss is
; seeded there (a motive the detective layer can read), instead of a faceless
; world-lane firing. The worker is the goal focus.
;
;   sack_go     : hold the goal, not at the workplace -> travel act to it.
;   sack_dwell  : hold the goal, AT the workplace -> a short dwell (the dismissal).
;   sack_commit : completion (completion-only) - fires the worker, drops his warmth
;                 toward the boss (the grudge), and clears the goal.
; ----------------------------------------------------------------------------

(hsim-event sack_go
  (intra-day)
  (nl   "@self sets out to dismiss a man")
  (when (and (has-goal sack)
             (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (not (self-at ?wp))))
  (utility 82)
  (effects (go @self ?wp)))

(hsim-event sack_dwell
  (intra-day)
  (nl   "@self deals with a failing man")
  (when (and (has-goal sack)
             (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (self-at ?wp)))
  (utility 82)
  (effects (act sack_commit 45)))

(hsim-event sack_commit
  (schedule (completion-only))
  (nl   "@self dismisses a worker")
  (effects
    (fire :worker (goal-focus sack))
    ; the grudge: the dismissed man resents the boss who let him go (a named motive)
    (nudge-stance (goal-focus sack) @self warmth -0.5)
    (clear-goal @self sack)
    (log _job_loss @self)))
