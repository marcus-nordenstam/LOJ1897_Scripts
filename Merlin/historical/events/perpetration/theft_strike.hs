; ----------------------------------------------------------------------------
; theft_strike - the place-emergent THEFT cascade-terminal (4.13 Phase G).
;
; The theft analog of means_strike. Fired ONLY by run_theft_strikes (preset
; ?thief), after that dispatcher has chosen the thief's scene (an occupied
; non-home same-town residence to burgle, or their own workplace to embezzle)
; and PLACED the thief there. The (steal ?thief) terminal routes to the engine's
; commit_theft_strike, which takes the loot at the recorded scene (the steal
; place-lane, run_generative_perpetration) and, for a burglary, runs the
; household confrontation (an awake / woken resident sets upon the intruder; the
; thief fights to flee or kills to escape; the householder repels). Replaces the
; bespoke fire_thefts loop's inline commit.
;
; Marked location-pass in run_tick (dispatcher-only): never fired by the DES or
; the per-NPC pass. The scene-choice + co-presence (the thief is physically AT
; the scene) live in the dispatcher; this event is the declarative commit.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event theft_strike
  (nl   "?thief steals at the scene")
  (kind _theft_strike)
  (rng-stream theft)

  (roles (role ?thief (template any_human)))

  (effects
    (steal ?thief)))
