; ----------------------------------------------------------------------------
; derive_prototypes - the F3.5 cascade. PER-NPC: each adult re-appraises ITSELF
; (wealth/piety/sobriety -> economic / respectability situations -> deserving_poor
; / undeserving_poor prototypes), caching each as a belief in its OWN mind. Pure
; self-analysis, no cross-NPC, no world mutation - so it runs in the per-NPC
; (sim-window-think) window-start pass with @self bound. No role casting.
;
; Gated to December (in-month): the cached prototype refreshes once a year.
; derive-prototypes is idempotent - a re-run just refreshes it from current state.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think derive_prototypes
  (sim-window-think)
  (rng-stream behaviour)

  (role @self )

  ; years-old + in-month are non-belief ops, so they gate the fire in (when).
  (when (and (in-month december)
             (>= (years-old @self) 15)))

  (cont-fire-effects
    (derive-prototypes @self)))
