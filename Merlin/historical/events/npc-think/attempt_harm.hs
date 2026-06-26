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

; CHOOSE-METHOD runs as a (long-term-think): it fires in the per-NPC window-start
; pass (the world lane skips crime events as dormant), routing a violent kill into
; the emergent fight (the C++ melee branch mints {@self goal {@self fight V}} and
; fight.hs plays it out blow by blow). Non-melee methods (poison / traps / fire)
; still commit through the terminal.
(hsim-event attempt_harm
  (long-term-think)
  (rng-stream perpetration)
  (generative-perpetration)

  (roles
    (role @self (template any_human)
                (> (count-beliefs @self goal) 0))))
