; ----------------------------------------------------------------------------
; Background old-age mortality. PER-NPC: a death happens to a specific person
; when their time has come - it is NOT a world rule. So @self is bound to each
; living NPC and rolls that NPC's own monthly mortality. No role casting - @self
; IS the subject.
;
; (die @self) only MARKS the NPC dead (writes death-date, condition=dead); the
; corpse is destroyed later by the zero-role burial sweep. propagate-death runs
; first (it needs @self's living relations to still resolve).
; ----------------------------------------------------------------------------

; mortality_by_age is auto-loaded from tables/.

(think mortality-old-age
  ; PER-NPC: fires once a month for each living NPC (self_actor = @self).
  ; The per-age (when (chance ?per_month)) IS the rate; the monthly cooldown is the cadence.
  (cooldown 1 m try-once)
  (rng-stream deaths)

  (role @self {@self age ?age}

    (bind (cond
            (case (< ?age 15) 0.006)
            (case (< ?age 40) 0.005)
            (case (< ?age 55) 0.010)
            (case (< ?age 65) 0.022)
            (case (< ?age 75) 0.050)
            (case (< ?age 85) 0.110)
            (case (< ?age 95) 0.220)
            (else 1.000)) ?per_year)
    (bind (/ ?per_year 12.0) ?per_month)

    (when (and (>= ?age 15)
               (chance ?per_month)))

    (utility survival)
    (effects (begin-goal {@self DIE [k death-cause old-age]}))
))
