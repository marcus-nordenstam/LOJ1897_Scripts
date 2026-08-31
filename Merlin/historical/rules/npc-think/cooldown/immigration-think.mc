; ----------------------------------------------------------------------------
; Immigration - the sparse-side population valve, as a GATEKEEPER decision (the
; mirror of emigration.hs's crowded-side per-NPC outflow).
;
; Admitting a newcomer is not a world concern any more than emigration is: it is
; an act of a SPECIFIC official - the town's senior civic gatekeeper (the [k job
; official] a senior_appointment installs at a public gov org). So @self is
; bound to each living NPC; the
; (grown @self) template + the (any {@self job [k job official]}) gate cast
; @self down to a holder of a senior public post, reading his OWN job belief (no
; scan, no telepathy). While the parish is sparse he quietly admits arrivals;
; each admission raises (living-npc-count), so (population-pressure) climbs toward the
; immigration threshold and the chance decays to zero - self-limiting, no sweep.
;
; The chance is scaled by SPARSENESS: (immigration_pressure - population_pressure),
; positive only below the threshold (the explicit (< ...) guard keeps the chance
; arg positive when it is rolled). The emptier the parish, the harder the pull; at
; the threshold it stops. Each fire admits exactly ONE arrival via
; (spawn-immigrant-wave 1) - the ONE authored way content calls the content-free
; creation primitive (all fractions/origins/jobs are authored knobs, no C++
; defaults). No count, no wave, no iteration. Ambient scalar reads
; ((population-pressure), decision #1) are allowed in the gate.
;
; (cooldown 1 m): the admission fires at most once per calendar month per
; eligible official. That once-per-month cadence, gated by the sparseness (chance), IS
; the "one admission per cycle while sparse" valve. Creating an entity mid-iteration
; is safe - the arrival is appended to the env, not to the pre-collected agent list this
; rule walks (cf. births.hs); only DESTROYING an entity would corrupt the walk.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; Per-official monthly admission rate at unit sparseness. Sized so a near-empty
; parish pulls hard and the rate tapers smoothly to zero as (population-pressure)
; approaches (homeostat_immigration_pressure) - replacing the old flat 6/year step.
(define-macro immigrant_admit_scale () 0.5)

(npc-think admit_immigrant
  (cooldown 1 m)
  (rng-stream migrations)

  ;; The gatekeeper: an adult holding a senior public post ([k job official],
  ;; installed by senior_appointment). His job belief is his own - a CACHED
  ;; self-gate filter, so every non-official empty-set-skips the rule.
  (role @self (grown @self)
              {@self job [k job official]})

  ;; Fire only while sparse, and then with a sparseness-scaled monthly chance. The
  ;; (< ...) guard fires the (and ...) only below the threshold, so the (chance ...)
  ;; argument is strictly positive whenever it is rolled.
  (when (and (< (population-pressure) (homeostat_immigration_pressure))
             (chance (* (immigrant_admit_scale)
                        (- (homeostat_immigration_pressure) (population-pressure))))))

  ;; Admit exactly ONE arrival - the full authored immigrant model, no C++ defaults.
  (effects
    (spawn-immigrant-wave 1)
    ))
