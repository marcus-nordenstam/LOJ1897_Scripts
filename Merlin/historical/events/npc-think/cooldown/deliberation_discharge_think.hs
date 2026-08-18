; ----------------------------------------------------------------------------
; The deliberation-lane discharge. When a migrated crime TASK concludes /succ, the
; deed happened, so the driving pressure (the task's /caused_by chain) is discharged -
; the deliberation lane owns the pressure, never the task itself. Modelled on burgle's
; steal_done discharge; but a task's /succ record PERSISTS (no goal to end), so a
; cooldown + a recency gate bound this to ~one discharge per completion instead of a
; per-cycle re-fire. /fail does NOT discharge - a failed attempt leaves the pressure
; live to drive another try next deliberation.
;
; GROWS as crimes migrate: add a rung per migrated crime whose /succ should discharge
; its pressure (confess_letter is the pilot). report_crime / confess are lawful outlets,
; but a concluded outlet still spends the grievance that drove it.
; ----------------------------------------------------------------------------

(npc-think discharge_confess_letter
  (cooldown 1 m)
  (role @self (believes {@self confess_letter ? /succ}:?rec))
  (when (and (caused-by ?rec {@self pressure ?})
             (< (days-since-last {@self confess_letter ? /succ}) 40)))
  (effects
    (caused-by ?rec {@self pressure ?}): ?p
    (discharge-pressure ?p 0.75)))

(npc-think discharge_report_crime
  (cooldown 1 m)
  (role @self (believes {@self report_crime ? /succ}:?rec))
  (when (and (caused-by ?rec {@self pressure ?})
             (< (days-since-last {@self report_crime ? /succ}) 40)))
  (effects
    (caused-by ?rec {@self pressure ?}): ?p
    (discharge-pressure ?p 0.75)))
