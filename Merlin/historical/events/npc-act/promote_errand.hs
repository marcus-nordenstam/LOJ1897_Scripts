; ----------------------------------------------------------------------------
; promote_errand - the npc-ACT half of the employer-side promotion split (Item 5).
;
; The decision (employment.hs `promotion`) minted {@self goal {@self promote_staff
; <worker>}} on the BOSS. He goes to the workplace and advances the worker's grade
; there. The worker is the goal focus.
;
;   promote_go     : hold the goal, not at the workplace -> travel act to it.
;   promote_dwell  : hold the goal, AT the workplace -> a short dwell.
;   promote_commit : completion (chain-only) - promotes the worker + clears the goal.
; ----------------------------------------------------------------------------

(hsim-event promote_go
  (intra-day)
  (nl   "@self sets out to advance a man")
  (when (and (has-goal promote_staff)
             (not (self-at (workplace-of @self)))))
  (utility 82)
  (effects (go @self (workplace-of @self))))

(hsim-event promote_dwell
  (intra-day)
  (nl   "@self reviews a worthy man")
  (when (and (has-goal promote_staff)
             (self-at (workplace-of @self))))
  (utility 82)
  (effects (act promote_commit 45)))

(hsim-event promote_commit
  (schedule (chain-only))
  (nl   "@self promotes a worker")
  (effects
    (promote :worker (goal-focus promote_staff))
    (clear-goal @self promote_staff)
    (log _promotion @self)))
