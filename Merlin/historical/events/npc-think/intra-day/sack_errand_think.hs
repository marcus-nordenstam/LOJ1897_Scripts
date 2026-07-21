; ----------------------------------------------------------------------------
; sack_errand (npc-think) - the go/dwell half of the employer-side job-loss split.
;
; The decision (employment.hs `job_loss`) minted {@self goal {@self sack
; <worker>}} on the BOSS (the org-head). The boss goes to the workplace and lets
; the man go in person - and the sacked man's grudge toward the NAMED boss is
; seeded there (a motive the detective layer can read), instead of a faceless
; world-lane firing. The worker is the goal focus. The completion commit
; (sack_act) lives in npc-act/sack_errand.hs.
;
;   sack_go     : hold the goal, not at the workplace -> travel act to it.
;   sack_dwell  : hold the goal, AT the workplace -> a short dwell (the dismissal).
; ----------------------------------------------------------------------------

(npc-think sack_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self sack})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (not (at-workplace ?wp))))
  (utility 82)
  (effects       (begin-goal {@self enter ?wp}))
  (cease-effects (end-goal   {@self enter ?wp})))

(npc-think sack_dwell
  (schedule on-commit)
  (goal {@self sack})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (at-workplace ?wp)))
  (utility 82)
  (effects       (begin-goal {@self sack}))
  (cease-effects (end-goal   {@self sack})))
