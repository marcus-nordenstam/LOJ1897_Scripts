; ----------------------------------------------------------------------------
; derive_prototypes - the F3.5 cascade. PER-NPC: each adult re-appraises ITSELF
; (wealth/piety/sobriety -> economic / respectability situations -> deserving-poor
; / undeserving-poor prototypes), caching each as a belief in its OWN mind. Pure
; self-analysis, no cross-NPC, no world mutation - @self is the subject. No role
; casting.
;
; Gated to December (in-month): the cached prototype refreshes once a year.
; derive-prototypes is idempotent - a re-run just refreshes it from current state.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think derive_prototypes
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self )

  ; years-old + in-month are non-belief ops, so they gate the fire in (when).
  (when (and (in-month 12)
             (>= (years-old @self) 15)))

  (effects
    (derive-prototypes @self)))
