; ----------------------------------------------------------------------------
; Background disease mortality. A flat low per-month chance independent of age -
; the steady drumbeat of fevers, consumption, accidents and respiratory illness.
; PER-NPC: it happens to a specific person, with @self as the subject - no role
; casting.
;
; Pandemic surges (cholera, smallpox, typhus) are a SEPARATE concern: a world-act
; sets an epidemic env state and a per-NPC roll tests against it. This rule is
; only the age-independent background rate.
;
; (die @self) marks @self dead (condition/death-date); the zero-role burial sweep
; destroys the corpse later. propagate-death first (reads @self's living ties).
; ----------------------------------------------------------------------------


(npc-think mortality_disease
  (cooldown 1 m try-once)
  (rng-stream deaths)

  (role @self 

    ; years-old is a non-belief op, so the age gate lives in (when), not the role.
    (when (and (>= (years-old @self) 1)
               (chance 0.0008)))   ; ~1% per year background disease rate

    (utility survival)
    (effects (begin-goal {@self DIE [k death-cause disease]}))))
