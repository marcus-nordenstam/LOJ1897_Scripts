; ----------------------------------------------------------------------------
; Background old-age mortality. PER-NPC: a death happens to a specific person
; when their time has come - it is NOT a world event. So @self is bound to each
; living NPC and rolls that NPC's own monthly mortality. No role casting - @self
; IS the subject.
;
; (die @self) only MARKS the NPC dead (writes death_date, condition=dead); the
; corpse is destroyed later by the zero-role burial sweep. propagate-death runs
; first (it needs @self's living relations to still resolve).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")
; mortality_by_age is auto-loaded from historical/tables/.

(npc-think mortality_old_age
  ; PER-NPC: fires once a month for each living NPC (self_actor = @self).
  ; The per-age (when (chance ?per_month)) IS the rate; the monthly cooldown is the cadence.
  (cooldown 1 m)
  (rng-stream deaths)

  (role @self )

  ; years-old is a non-belief op, so the age gate lives in (when), not the role.
  (mortality_by_age (years-old @self)):?per_year
  (/ ?per_year 12.0):?per_month

  (when (and (>= (years-old @self) 15)
             (chance ?per_month)))

  (effects
    ; propagate-death MUST precede die - die marks @self dead, and propagation
    ; reads @self's still-living kin/social ties to spread the death belief.
    (propagate-death @self)
    (record-corpse-death @self [k death_cause old_age])
    )
)
