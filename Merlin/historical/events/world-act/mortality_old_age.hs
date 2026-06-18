; ----------------------------------------------------------------------------
; Background old-age mortality. Per-NPC monthly roll; rate climbs with age.
; This is the canonical "data-driven vitals" event - everything that used
; to live in vitals.cc as hardcoded C++ now sits in this file.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")
(include "../../definitions/tables.hs")

(hsim-event mortality_old_age
  (nl         "?who dies of old age")
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass.
  ; The per-age (when (chance ?per_month)) below IS the rate; the monthly pass
  ; is the cadence.
  (rng-stream deaths)

  (roles
    (role ?who (template old_human)))

  (let ((?per_year  (lookup mortality_by_age (years-old ?who)))
        (?per_month (/ ?per_year 12.0)))

    (when (chance ?per_month))

    (effects
      ; propagate-death MUST precede die - see mortality_disease.hse for
      ; the rationale.
      (propagate-death ?who)
      (die             ?who :cause old_age)
      (log             _death ?who)))
)
