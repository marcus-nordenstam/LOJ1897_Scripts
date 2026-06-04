; ----------------------------------------------------------------------------
; deliberate.hse - Phase 10 Phase D Pivot A (2026-05-24).
;
; The ONE deliberation event. Plan section 10.3c.
;
; There is no taxonomy of named deliberation events. Earlier drafts proposed
; 7 (resolve_to_confess / resolve_on_a_secret / resolve_on_a_rival / ...);
; each was a specific (pressure-kind, action-set) instantiation expressing
; the same shape. That set is itself a finite taxonomy of story openings -
; an actor whose pressure profile doesn't map cleanly to one of them never
; deliberates. DELETED.
;
; The replacement: ONE event whose branches are NOT authored. They are
; SYNTHESIZED at fire-time from the actor's standing pressure stack x the
; affinity table in historical/config/deliberation.hsc. The branch-set
; lives entirely outside this file - new pressures / new actions / new
; affinities are .hsc rows, not new events.
;
; CAST FILTER: any alive human carrying a non-trivial standing pressure of
; any kind. The (total-pressure-load ?actor) reader will land in the
; next sub-PR; for PR-1 we sum a representative pressure kind directly.
;
; OUTCOME: synthesized at fire-time by the engine (see hsim/deliberation.cc
; and hsim/hse_engine.cc::run_generative_deliberation). The (generative-
; deliberation) flag tells the engine to take that path; the event must NOT
; also author (effects ...) or (branches ...).
;
; PR-1 OUTPUT: a narrative entry "deliberate: <actor> -> <action>" per
; fire. Follow-up PRs wire the chosen action to nested goal-belief minting
; ({actor goal {actor <action> <focus>}}) and to action-pipeline consumers.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event deliberate
  (nl       "?actor weighs their pressure load and acts")
  (kind     _deliberate)
  (schedule (monthly))
  (rng-stream deliberation)

  (roles
    (role ?actor (template any_human)
                 ; TEMP: pass every alive human while we validate the wiring.
                 ; The real OR-of-pressures filter is the comment block below;
                 ; restore once we've confirmed deliberate fires + synthesizer
                 ; produces branches.
                 (> (emotion-load ?actor) -1.0)))

  (generative-deliberation))
