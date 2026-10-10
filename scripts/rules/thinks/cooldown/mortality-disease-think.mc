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
; The roll is latched: the DIE it proposes holds until it is done, and a hold re-check must not
; roll again. (die @self) marks @self dead (condition/death-date); the zero-role burial sweep
; destroys the corpse later. propagate-death first (reads @self's living ties).
; ----------------------------------------------------------------------------


(driver mortality-disease
  (cooldown 1 m try-once)
  (rng-stream deaths)

  (role @self {@self age ?age}

    (when (and (>= ?age 1)
               (latch-eval (chance 0.0008))))   ; ~1% per year background disease rate

    (declare-utility survival)
    (effects (maintain-proposal {@self DIE [k disease-death]}))))
