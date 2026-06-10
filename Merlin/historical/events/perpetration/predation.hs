; ----------------------------------------------------------------------------
; predation.hs - appetitive homicide genesis (serial_predation plan Phase 2).
;
; The sixth generative kill pass, and the first APPETITIVE one: the reward
; is the killing itself (sadism / power), not inheritance, passion, a seat,
; or silencing a witness. Victims are chosen for SOCIAL INVISIBILITY - low
; prestige, destitute / disreputable, small social circle - and the scan is
; the whole population, NOT the actor's orbit (predators hunt outside it).
;
; The `(generative-predation)` flag dispatches to hse_engine.cc::
; run_generative_predation, which (per alive adult, monthly):
;   1. hard trait tail: mean lethal disposition (psychopathy + sadism)
;      must clear k_predation_trait_floor - only the top tail EVER
;      qualifies, and the gate is stable per-NPC, so seriality emerges
;      from re-passing it month after month;
;   2. rate gate: k_predation_base_rate x disinhibition x lethal
;      disposition, x k_predation_power_aim_mult for {@self life_aim
;      power_aim} holders;
;   3. seeds the per-predator fixation ({@self fixation <gender>}, once,
;      stable for life - victim-type consistency without authoring it);
;   4. scores every eligible non-kin adult by invisibility and
;      weighted-samples ONE victim. Small circle = few mourners = small
;      Phase-1 violent-verdict fan-out, so invisible victims are
;      MECHANICALLY safer - the loop the Cream case study runs on;
;   5. mints the stalk_target marker (~30 days; attempt_harm reads it as
;      a weight multiplier - the prepared predator's surprise) and the
;      kill goal, /cause-pinned to the life_aim / sadism self-belief so
;      the rap-sheet chain stays legible.
; attempt_harm then consumes the goal and executes a method as usual -
; a poisoner-predator emerges when the method affinity favours poison.
;
; Kept a tail by design (trait floor + base rate): the target is 1-3
; predators per few generations. To A/B, rename/remove this file.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event predation
  (nl       "?actor's appetite turns predatory")
  (kind     _predation)
  (schedule (monthly))
  (rng-stream perpetration)
  (generative-predation)

  (roles
    (role ?actor (kind human)
      (alive)
      (>= (years-old ?actor) 18))))
