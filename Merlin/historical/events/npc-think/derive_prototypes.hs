; ----------------------------------------------------------------------------
; derive_prototypes - the F3.5 cascade. PER-NPC: each adult re-appraises ITSELF
; (wealth/piety/sobriety -> economic / respectability situations -> deserving_poor
; / undeserving_poor prototypes), caching each as a belief in its OWN mind. Pure
; self-analysis, no cross-NPC, no world mutation - so it runs in the per-NPC
; (long-term-think) window-start pass with @self bound. No role casting.
;
; Gated to winter (the old event ran annually in December; there is no month-only
; op, so winter is the nearest gate). derive-prototypes is idempotent - re-running
; it across Dec/Jan/Feb just refreshes the cached prototype from current state.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event derive_prototypes
  (long-term-think)
  (rng-stream behaviour)

  (roles
    (role @self (template any_human)))

  ; years-old + in-season are non-belief ops, so they gate the fire in (when).
  (when (and (>= (years-old @self) 15)
             (in-season winter)))

  (effects
    (derive-prototypes @self)))
