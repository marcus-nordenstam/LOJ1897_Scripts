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
  (role @self (believes {@self confess_letter ? /succ}:?rec-rel))
  (when (and (caused-by ?rec-rel {@self pressure ?})
             (< (days-since-last {@self confess_letter ? /succ}) 40)))
  (effects
    (caused-by ?rec-rel {@self pressure ?}): ?p-rel
    (discharge-pressure ?p-rel 0.75)))

(npc-think discharge_report_crime
  (cooldown 1 m)
  (role @self (believes {@self report_crime ? /succ}:?rec-rel))
  (when (and (caused-by ?rec-rel {@self pressure ?})
             (< (days-since-last {@self report_crime ? /succ}) 40)))
  (effects
    (caused-by ?rec-rel {@self pressure ?}): ?p-rel
    (discharge-pressure ?p-rel 0.75)))

(npc-think discharge_coerce
  (cooldown 1 m)
  (role @self (believes {@self coerce ? /succ}:?rec-rel))
  (when (and (caused-by ?rec-rel {@self pressure ?})
             (< (days-since-last {@self coerce ? /succ}) 40)))
  (effects
    (caused-by ?rec-rel {@self pressure ?}): ?p-rel
    (discharge-pressure ?p-rel 0.75)))

(npc-think discharge_expose
  (cooldown 1 m)
  (role @self (believes {@self expose ? /succ}:?rec-rel))
  (when (and (caused-by ?rec-rel {@self pressure ?})
             (< (days-since-last {@self expose ? /succ}) 40)))
  (effects
    (caused-by ?rec-rel {@self pressure ?}): ?p-rel
    (discharge-pressure ?p-rel 0.75)))

(npc-think discharge_humiliate
  (cooldown 1 m)
  (role @self (believes {@self humiliate ? /succ}:?rec-rel))
  (when (and (caused-by ?rec-rel {@self pressure ?})
             (< (days-since-last {@self humiliate ? /succ}) 40)))
  (effects
    (caused-by ?rec-rel {@self pressure ?}): ?p-rel
    (discharge-pressure ?p-rel 0.75)))

(npc-think discharge_frame
  (cooldown 1 m)
  (role @self (believes {@self frame ? /succ}:?rec-rel))
  (when (and (caused-by ?rec-rel {@self pressure ?})
             (< (days-since-last {@self frame ? /succ}) 40)))
  (effects
    (caused-by ?rec-rel {@self pressure ?}): ?p-rel
    (discharge-pressure ?p-rel 0.75)))

(npc-think discharge_bribe
  (cooldown 1 m)
  (role @self (believes {@self bribe ? /succ}:?rec-rel))
  (when (and (caused-by ?rec-rel {@self pressure ?})
             (< (days-since-last {@self bribe ? /succ}) 40)))
  (effects
    (caused-by ?rec-rel {@self pressure ?}): ?p-rel
    (discharge-pressure ?p-rel 0.75)))

(npc-think discharge_seduce
  (cooldown 1 m)
  (role @self (believes {@self seduce ? /succ}:?rec-rel))
  (when (and (caused-by ?rec-rel {@self pressure ?})
             (< (days-since-last {@self seduce ? /succ}) 40)))
  (effects
    (caused-by ?rec-rel {@self pressure ?}): ?p-rel
    (discharge-pressure ?p-rel 0.75)))

; hurt: a displaced-rage beating (displace_kill) spends the original grievance once done.
(npc-think discharge_hurt
  (cooldown 1 m)
  (role @self (believes {@self hurt ? /succ}:?rec-rel))
  (when (and (caused-by ?rec-rel {@self pressure ?})
             (< (days-since-last {@self hurt ? /succ}) 40)))
  (effects
    (caused-by ?rec-rel {@self pressure ?}): ?p-rel
    (discharge-pressure ?p-rel 0.75)))
