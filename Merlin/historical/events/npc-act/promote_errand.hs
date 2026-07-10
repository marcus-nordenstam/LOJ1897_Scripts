; ----------------------------------------------------------------------------
; promote_errand - the npc-ACT half of the employer-side promotion split (Item 5).
;
; The decision (employment.hs `promotion`) minted {@self goal {@self promote_staff
; <worker>}} on the BOSS. He goes to the workplace and advances the worker's grade
; there. The worker is the goal focus.
;
;   promote_go     : hold the goal, not at the workplace -> travel act to it.
;   promote_dwell  : hold the goal, AT the workplace -> a short dwell.
;   promote_commit : completion (completion-only) - promotes the worker + clears the goal.
; ----------------------------------------------------------------------------

(npc-think promote_go
  (short-term-think)
  (goal {@self promote_staff})
  (when (and (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (not (at-place ?wp))))
  (utility 82)
  (cont-fire-effects (excl-goal {@self go ?wp})))

(npc-think promote_dwell
  (short-term-think)
  (goal {@self promote_staff})
  (when (and (bind {@self employer ?org})
             (bind {?org workplace ?wp})
             (at-place ?wp)))
  (utility 82)
  (effects (begin-act {@self promote_staff} 45 promote_commit)))

(npc-think promote_commit
  (on-completion)
  (effects
    (promote /worker (goal-focus promote_staff))
    (end-goal {@self promote_staff})
    ))
