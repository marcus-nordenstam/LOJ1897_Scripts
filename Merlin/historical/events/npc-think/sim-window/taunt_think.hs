; ----------------------------------------------------------------------------
; taunt.hs - narcissist self-insertion (serial_predation).
;
; The Cream signature: a narcissistic murderer inserts himself into the
; public mystery his own crime created. PURE .hs (no C++ generator) -
; sibling of predation.hs / covet_inheritance.hs:
;   - (when ...) is the narcissism tail (>= 0.7, env ground truth), the
;     adult floor, and the per-corpse-window-month base rate (0.04);
;   - (covert-kill-corpse) resolves the actor's own recent OVERT-method
;     murder victim whose corpse is still in its pre-burial window (an overt
;     corpse's violent verdict at burial is inevitable, and the killer KNOWS
;     his method was overt - no waiting for the inquest). The one
;     irreducible belief-x-method-table scan, exposed as a verb;
;   - (random-alive-human @self ?victim) picks the INNOCENT to accuse -
;     uniformly, so repeated letters do not accuse the same early-slot NPC;
;   - (effects ...) plants the forged_letter {innocent kill victim} in the
;     actor's OWN home mail pile (the kept draft - discoverable evidence).
;     (msg ...) composes it ANONYMOUS through the shared letter codec; the
;     claimed knowledge ("who did it") is the player-facing tell.
;
; hsim does NOT react to the letter beyond normal document existence - no
; investigation arc (that is the player's job, the hard no-justice rule).
; To A/B, rename/remove this file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think taunt
  (sim-window-think)
  (rng-stream perpetration)

  (role @self (any_human @self)
              (adult @self))

  ; Narcissism tail + adult floor + rate gate.
  (when (and (>= (attr @self narcissism) 0.7)
             (chance 0.04)))

  (cont-fire-effects
    ; The actor's own recent overt-method kill, corpse still pre-burial;
    ; @fail (no letter) when there is none - the taunt needs a live mystery.
    (bind (covert-kill-corpse) ?victim)
    (if (is-entity ?victim)
        (do
          (bind (random-alive-human @self ?victim) ?innocent)
          (bind (target {@self home}) ?home)
          (if (and (is-entity ?innocent) (is-entity ?home))
              (spawn-letter [k forged_letter]
                            (msg {?innocent kill ?victim})
                            ?home))))))
