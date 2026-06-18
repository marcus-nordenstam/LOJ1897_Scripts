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
;   3. seeds the per-predator victim-type PROFILE once, stable for life:
;      repeated {@self fixation <trait-value>} beliefs, 1-2 trait axes
;      copied off a random living-adult "type prototype" person. The axes
;      are authored as (fixation-axis <name>) rows in
;      definitions/perpetration.hs (gender / height / girth / appearance /
;      hair_color / eye_color / nationality / class_situation / job) -
;      adding one there needs no C++. Sampling a real person weights
;      profiles by population frequency and guarantees the profile is
;      achievable; victim-type consistency EMERGES without authoring it
;      ("tall blond men", "disreputable working girls", ...);
;   4. HARD-filters every eligible non-kin adult to the full profile, then
;      scores the survivors by invisibility and weighted-samples ONE
;      victim. Small circle = few mourners = small Phase-1 violent-verdict
;      fan-out, so invisible victims are MECHANICALLY safer - the loop the
;      Cream case study runs on. A predator whose profile matches nobody
;      this tick stays latent until a victim of his type exists;
;   5. mints the stalk_target marker (~30 days; attempt_harm reads it as
;      a weight multiplier - the prepared predator's surprise) and the
;      kill goal, /cause-pinned to the first fixation belief (else the
;      power_aim life_aim) so the rap-sheet chain stays legible
;      ("kill <victim> <- {@self fixation blonde}").
; attempt_harm then consumes the goal and executes a method as usual -
; the MO is whatever the method affinity favours (a skilled apothecary
; poisons, a soldier strangles or stabs); nothing here is poison-bound.
;
; Kept a tail by design (trait floor + base rate): the target is 1-3
; predators per few generations. To A/B, rename/remove this file.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event predation
  (nl       "?actor's appetite turns predatory")
  (rng-stream perpetration)
  (generative-predation)

  (roles
    (role ?actor (kind [k human])
      (alive)
      (>= (years-old ?actor) 18))))
