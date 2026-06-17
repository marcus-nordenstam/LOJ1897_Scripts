; ----------------------------------------------------------------------------
; attempt_harm.hse - PR-3d 2026-05-25.
;
; The one generative-perpetration event. Replaces the per-method .hse
; files (improvised_kill, perpetrate_goal, the planned
; tamper_with_substance et al.) with a single event whose branches are
; synthesized at fire-time from the cast actor's standing goal beliefs
; cross-product with the perpetration.hsc method rows.
;
; The `(generative-perpetration)` flag tells the engine to bypass
; `(effects)` / `(branches)` and dispatch to
; `hsim/perpetration.cc::run_generative_perpetration`. That function:
;   1. Walks actor's `{actor goal ...}` beliefs.
;   2. For each goal, filters perpetration.hsc rows by :goal-fit +
;      :requires + :victim-state + :in-season.
;   3. Composes weights: base * disinhibition * pressure-floor.
;   4. Weighted-samples; dispatches the chosen row's :terminal.
;
; Monthly schedule - actors with standing goals attempt perpetration
; opportunistically. The `(> (count-beliefs ?actor goal) 0)` filter
; restricts the cast to goal-holding NPCs; non-goal-holders never
; perpetrate.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event attempt_harm
  (nl       "?actor follows through on a standing perpetration goal")
  (kind [k _attempt_harm])
  (band      night)
  (rng-stream perpetration)
  (generative-perpetration)

  (roles
    (role ?actor (template any_human)
                 (> (count-beliefs ?actor goal) 0))))
