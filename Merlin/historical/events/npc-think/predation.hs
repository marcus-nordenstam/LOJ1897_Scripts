; ----------------------------------------------------------------------------
; predation.hs - appetitive homicide genesis (serial_predation).
;
; The first APPETITIVE generative kill motive: the reward is the killing
; itself (sadism / power), not inheritance, passion, a seat, or silencing a
; witness. Victims are chosen for SOCIAL INVISIBILITY - low prestige,
; destitute / disreputable, small social circle - and the scan is the whole
; population, NOT the actor's orbit (predators hunt outside it).
;
; PURE .hs (no C++ generator). Sibling of covet_inheritance.hs / ambition.hs.
; The selection that the old (generative-predation) flag dispatched to
; run_generative_predation is expressed here with the engine's scored
; select-one primitive, exposed as the (predation-target @self) verb:
;   - (when ...) is the disposition pre-gate (the HARD trait tail: only the
;     top lethal-disposition tail - mean(psychopathy, sadism) >= 0.65 - EVER
;     qualifies, stable per-NPC, so seriality emerges from re-passing it month
;     after month) + the adult floor + the rate (0.005 * disinhibition-scaled
;     propensity, DOUBLED for {@self life_aim power_aim} holders);
;   - (predation-target @self) seeds the per-predator victim-type PROFILE once
;     on the first hunt (repeated {@self fixation <trait-value>} beliefs, 1-2
;     trait axes copied off a random living-adult "type prototype" - so
;     victim-type consistency EMERGES, "tall blond men", "disreputable working
;     girls", and the profile is achievable), then HARD-filters every eligible
;     non-kin adult to the full profile and weighted-samples ONE by
;     invisibility. Small circle = few mourners = small violent-verdict
;     fan-out, so invisible victims are MECHANICALLY safer (the Cream-case
;     loop). The one irreducible computation, exposed as a verb (sibling of
;     (heir-apparent ...) / (ambition-target ...)). @fail when the profile
;     matches nobody this tick - the predator stays latent until a victim of
;     his type exists;
;   - (effects ...) mints the kill goal toward the resolved victim and arms the
;     stalk_target marker (mark-stalk - the ~30-day surprise modifier
;     attempt_harm reads as a weight multiplier). /cause pins the first
;     {@self fixation} belief - the legible appetitive signature - so the
;     rap-sheet reads "kill <victim> <- {@self fixation blonde}"; it falls back
;     to the power_aim life_aim belief when no profile was seedable.
; attempt_harm then consumes the goal and executes a method as usual - the MO
; is whatever the method affinity favours (a skilled apothecary poisons, a
; soldier strangles or stabs); nothing here is poison-bound.
;
; Kept a tail by design (trait floor + base rate): the target is 1-3 predators
; per few generations. To A/B the motive, rename / remove this file
; (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event predation
  (long-term-think)
  (rng-stream perpetration)

  (roles
    (role @self (template any_human)))

  ; Disposition pre-gate + adult floor + rate. lethal = mean(psychopathy, sadism);
  ; the >= 0.65 floor is the hard trait tail (only the top tail EVER qualifies).
  ; propensity = (1 - inhibition) * lethal; fire at 0.005 * propensity, doubled for
  ; {@self life_aim power_aim} holders.
  (when (and (>= (years-old @self) 18)
             (>= (* 0.5 (+ (attr @self psychopathy) (attr @self sadism))) 0.65)
             (chance (* (crime-scale) 0.005
                        (* (* (- 1 (target {@self inhibition}))
                              (* 0.5 (+ (attr @self psychopathy) (attr @self sadism))))
                           (if (believes {@self life_aim [k power_aim]}) 2.0 1.0))))))

  ; predation-target seeds the victim-type profile on the first hunt, then resolves
  ; the invisible victim (the irreducible scan, exposed as a verb). /cause pins the
  ; first fixation belief (the appetitive signature), else the power_aim life_aim
  ; belief. mark-stalk arms the surprise weight modifier attempt_harm reads.
  (effects
    (bind (predation-target @self) ?victim)
    (if (alive ?victim)
        (do
          (if (believes {@self fixation})
              (begin-goal {@self kill ?victim} /cause {@self fixation})
              (begin-goal {@self kill ?victim} /cause {@self life_aim [k power_aim]}))
          (mark-stalk ?victim)))))
