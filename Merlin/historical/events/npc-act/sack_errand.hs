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

(npc-think sack_go
  (short-term-think)
  (goal {@self sack})
  (when (and (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (not (at-place ?wp))))
  (utility 82)
  (cont-fire-effects (excl-goal {@self go ?wp})))

(npc-think sack_dwell
  (short-term-think)
  (goal {@self sack})
  (when (and (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (at-place ?wp)))
  (utility 82)
  (effects (begin-act {@self sack} 45 sack_commit)))

(npc-think sack_commit
  (on-completion)
  (effects
    (fire /worker (goal-focus sack))
    ; the grudge: the dismissed man resents the boss who let him go (a named motive)
    (nudge-stance (goal-focus sack) @self warmth -0.5)
    (end-goal {@self sack})
    ))
