; ----------------------------------------------------------------------------
; hire_errand - the npc-THINK half of the hiring split (employee-side approach).
; The worker holds {@self engage_staff}: travel to the firm, then dwell there.
; ----------------------------------------------------------------------------

(npc-think hire_go
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self engage_staff})
  (when (and (articles-building (goal-focus engage_staff) ?venue)
             (not (in-building ?venue))))
  (utility 82)
  (effects       (begin-goal {@self enter ?venue}))
  (cease-effects (end-goal   {@self enter ?venue})))

(npc-think hire_dwell
  (schedule on-commit)
  (goal {@self engage_staff})
  (when (and (articles-building (goal-focus engage_staff) ?venue)
             (in-building ?venue)))
  (utility 82)
  (effects       (begin-goal {@self engage_staff}))
  (cease-effects (end-goal   {@self engage_staff})))
