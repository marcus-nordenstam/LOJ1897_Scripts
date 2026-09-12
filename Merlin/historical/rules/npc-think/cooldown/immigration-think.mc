; ----------------------------------------------------------------------------
; Immigration - the sparse-side population valve, as a GATEKEEPER decision (the
; mirror of emigration.hs's crowded-side per-NPC outflow).
;
; Admitting a newcomer is not a world concern any more than emigration is: it is
; an act of a SPECIFIC official - the town's senior civic gatekeeper (the [k job
; official] a senior_appointment installs at a public gov org). So @self is bound
; to each living NPC; the age-band template + the {@self job [k job official]}
; gate cast @self down to a holder of a senior public post, reading his OWN job
; belief (no scan, no telepathy). While the parish is sparse he quietly admits
; arrivals; each admission raises (living-npc-count), so (population-pressure)
; climbs toward the immigration threshold and the chance decays to zero -
; self-limiting, no sweep.
;
; This rule DECIDES; it does not admit. The arrival is minted by the
; ADMIT-IMMIGRANT action, which is also where the free-house lookup lives - a
; think may not read the world any more than it may change it.
;
; The chance is scaled by SPARSENESS: (immigration_pressure - population_pressure),
; positive only below the threshold (the explicit (< ...) guard keeps the chance
; arg positive when it is rolled). The emptier the parish, the harder the pull; at
; the threshold it stops.
;
; (cooldown 1 m): the admission fires at most once per calendar month per
; eligible official. That once-per-month cadence, gated by the sparseness
; (chance), IS the "one admission per cycle while sparse" valve.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; Per-official monthly admission rate at unit sparseness. Sized so a near-empty
; parish pulls hard and the rate tapers smoothly to zero as (population-pressure)
; approaches (homeostat_immigration_pressure).
(define-macro immigrant_admit_scale () 0.5)

(npc-think admit_immigrant
  (cooldown 1 m)
  (rng-stream migrations)
  ; (population-pressure) is an AMBIENT SCALAR - how full the parish is, which
  ; an official knows from his own register. It names no object, so it reveals
  ; nothing @self has not perceived; the waive is for the read, not for a peek.
  (lint-waive env-read-outside-action)

  ;; The gatekeeper: an adult holding a senior public post ([k job official],
  ;; installed by senior_appointment). His job belief is his own - a CACHED
  ;; self-gate filter, so every non-official empty-set-skips the rule.
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self job [k job official]})

  ;; The premises he admits people AT, threaded off his own post: job -> org ->
  ;; workplace, three belief reads and no world lookup.
  (role ?job {@self job ?job})
  (role ?org {?job org ?org})
  (role ?office {?org workplace ?office})

  ;; Fire only while sparse, and then with a sparseness-scaled monthly chance. The
  ;; (< ...) guard fires the (and ...) only below the threshold, so the (chance ...)
  ;; argument is strictly positive whenever it is rolled.
  (population-pressure): ?pressure
  (when (and (< ?pressure (homeostat_immigration_pressure))
             (chance (* (immigrant_admit_scale)
                        (- (homeostat_immigration_pressure) ?pressure)))))

  (utility duty)

  (effects
    (maintain-proposal {@self ADMIT-IMMIGRANT ?office})))
