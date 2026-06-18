; ----------------------------------------------------------------------------
; taunt.hs - narcissist self-insertion (serial_predation plan Phase 4).
;
; The Cream signature: a narcissistic murderer inserts himself into the
; public mystery his own crime created. The `(generative-taunt)` flag
; dispatches to hse_engine.cc::run_generative_taunt, which (per alive adult,
; monthly):
;   1. narcissism tail (k_taunt_narcissism_floor),
;   2. rate gate (k_taunt_base_rate),
;   3. the actor must have a recent OVERT-method murder of their own - the
;      corpse still in its pre-burial window (an overt corpse's violent
;      verdict at burial is inevitable, and the killer KNOWS his method
;      was overt - no waiting for the inquest); the actor's own
;      leaf-task act-anchors (core memories post 4c-mem) are the source,
;   4. picks an INNOCENT and plants a forged_letter {innocent kill victim}
;      in the actor's own home (the kept draft) - physical evidence whose
;      claimed knowledge ("who did it") is the player-facing tell.
;
; hsim does NOT react to the letter beyond normal document existence - no
; investigation arc (that is the player's job, the hard no-justice rule).
; To A/B, rename/remove this file.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event taunt
  (nl       "?actor inserts themselves into their own mystery")
  (rng-stream perpetration)
  (generative-taunt)

  (roles
    (role ?actor (kind [k human])
      (alive)
      (>= (years-old ?actor) 18))))
