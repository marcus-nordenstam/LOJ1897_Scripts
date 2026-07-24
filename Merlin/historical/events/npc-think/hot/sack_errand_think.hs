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
;   sack_dwell  : hold the goal, AT the workplace -> propose the dismissal (sack_act).
; ----------------------------------------------------------------------------

(npc-think sack_go
  (goal {@self sack})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (not (at-workplace ?wp))))
  (utility 82)
  (effects (maintain-proposal {@self enter ?wp})))

; TERMINAL (act_body_purification): AT the workplace, PROPOSE the sack act - it no longer
; promotes off the bare {@self sack} goal (a proposed label drops out of goal competition).
; The ?org role binds ?wp (the workplace) for the arrived gate.
(npc-think sack_dwell
  (goal {@self sack})
  (role ?org (believes {@self employer ?org})
             (believes {?org workplace ?wp}))   ; ?wp binds at fire
  (when (and (at-workplace ?wp)))
  (utility 82)
  (effects (maintain-proposal {@self sack})))
