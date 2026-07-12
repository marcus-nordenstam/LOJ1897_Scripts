; ----------------------------------------------------------------------------
; hire_errand - the npc-THINK half of the hiring split (employee-side approach).
; The worker holds {@self engage_staff}: travel to the firm, then dwell there.
; ----------------------------------------------------------------------------

(npc-think hire_go
  (short-term-think)
  (goal {@self engage_staff})
  (when (and (articles-building (goal-focus engage_staff) ?venue)
             (not (in-building ?venue))))
  (utility 82)
  (cont-fire-effects (go-into ?venue)))

(npc-think hire_dwell
  (short-term-think)
  (goal {@self engage_staff})
  (when (and (articles-building (goal-focus engage_staff) ?venue)
             (in-building ?venue)))
  (utility 82)
  (cont-fire-effects (begin-goal {@self engage_staff})))
