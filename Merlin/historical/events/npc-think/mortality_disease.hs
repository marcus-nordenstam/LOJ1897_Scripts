; ----------------------------------------------------------------------------
; Background disease mortality. A flat low per-month chance independent of age -
; the steady drumbeat of fevers, consumption, accidents and respiratory illness.
; PER-NPC: it happens to a specific person, so it runs in the (long-term-think)
; window-start pass with @self bound to each living NPC - no role casting.
;
; Pandemic surges (cholera, smallpox, typhus) are a SEPARATE concern: a world-act
; sets an epidemic env state and a per-NPC roll tests against it. This event is
; only the age-independent background rate.
;
; (die @self) marks @self dead (condition/death_date); the zero-role burial sweep
; destroys the corpse later. propagate-death first (reads @self's living ties).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour mortality_disease
  (long-term-think)
  (rng-stream deaths)

  (roles
    (role @self (template any_human)))

  ; years-old is a non-belief op, so the age gate lives in (when), not the role.
  (when (and (>= (years-old @self) 1)
             (chance 0.0008)))   ; ~1% per year background disease rate

  (effects
    (propagate-death @self)
    (record-corpse-death @self [k death_cause disease])
    ))
