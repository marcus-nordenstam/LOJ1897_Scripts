; ----------------------------------------------------------------------------
; Population homeostat. The sparse-side feedback valve only.
;
;   homeostat_immigration: too sparse -> spawn N adult immigrants
;
; Immigration STAYS a world-act: spawning a brand-new arrival is pure creation -
; it casts no existing NPC's role (the new entity does not exist yet), so it does
; not violate the "world-acts never touch a specific NPC" rule.
;
; The crowded-side valve (the old homeostat_emigration: "emigrate the oldest N by
; fiat") was RETIRED. Reaching in to remove specific people is not a world concern;
; emigration is now a per-NPC decision (events/npc-think/emigration.hs) whose
; per-month chance scales with (population-pressure), and the actual removal is the
; zero-role (sweep-emigrants) sweep. So crowding raises the outflow organically.
;
; This event runs unconditionally each year - the (when ...) gate decides whether
; anything happens. The homeostat tunables live in macros/tunables.hs.
; ----------------------------------------------------------------------------

(hsim-world-event homeostat_immigration
  (schedule   (annually january))
  (rng-stream homeostat)

  (bind (alive-count)                    ?alive)
  (bind (homeostat_target_population)     ?target)
  (bind (/ ?alive ?target)               ?pressure)
  (bind (homeostat_immigration_count)    ?count)

  (when (< ?pressure (homeostat_immigration_pressure)))

  (effects
    (spawn-immigrant-wave ?count)
    )
)
