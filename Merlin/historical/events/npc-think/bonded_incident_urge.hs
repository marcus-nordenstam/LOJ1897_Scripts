; ----------------------------------------------------------------------------
; bonded_incident_urge (PR-A-7, 2026-05-28, v2 multiplicative).
;
; First organic caller of PR-A-5's (urge ...) effect verb. A legacy-aim
; parent with a substantial value-rift against their adult child
; applies an urge - a non-verbal-or-verbal pressure to atone.
;
; The plan's outcome row:
;   urge | low compassion x assertiveness
;        | triangulation-parental x (class-interloper + value-rift)
;        | LIFE_AIM_ALIGN +legacy, +respectability
;
; V2 gating: multiplicative-chance over (1 - compassion) x
; assertiveness on the actor side; structural amplifiers
; (triangulation-parental + class-interloper) need a 3-role binding
; (parent / child / romantic-partner) the .hse layer doesn't yet
; support cleanly, so V2 keeps the simpler legacy_aim parent + child
; + value-rift substrate. The 4-arg `(urge @self ?victim avoid ?partner)`
; shape lands when the 3-role binding ships.
;
; value-rift becomes an AMPLIFIER (not a hard gate): the modal NPC
; pair has rift = 0 today (no event mints value beliefs yet) so the
; 0.2 floor keeps urge alive across the population while letting a
; substantive divergence lift firing rate ~4x.
;
; categorize fires:
;   - the urge anchor itself (no construed_act tags on urge today;
;     reaction rows arrive when the appraisal cascade for `urge`
;     is authored).
;   - on success, {victim atone _} is minted directly on victim
;     (honour_act -> guilt + moral_violation pressure in actor's
;     mind via the appraisal cascade).
;
; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass
; (relational: parent-of-victim + value-rift, no co-presence). MONTHLY now, so
; the actor (chance) base is /12 (0.15 -> 0.0125) to hold the annual volume.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour bonded_incident_urge
  (long-term-think)
  (rng-stream incidents)

  (roles
    (role @self  (any_human @self))
    (role ?victim (any_human ?victim)
                  (not (= ?victim @self))
                  (believes {@self child ?victim})))

  ; Non-belief gates (moved out of the roles - none are cacheable belief queries):
  ;  - actor (chance): the plan's `+legacy, +respectability` for urge is a
  ;    LIFE_AIM_ALIGN AMPLIFIER, not a hard gate - applied via life-aim-aligns
  ;    inside the chance product (returns 0.4 for legacy_aim, 0.4 for
  ;    respectability_aim, ~0 for the neutral aims, -0.2 for autonomy_aim per
  ;    life_aim_affinity.hsc). `(+ 1.0 ...)` keeps the term non-negative
  ;    (life-aim-aligns is in [-1, 1] so the sum is [0, 2]) - compose_range
  ;    bails on mixed-sign multiplications, so the offset must be >= the
  ;    absolute min of the inner. Modal neutral-aim parent multiplier = 1.0;
  ;    legacy/respectability parent = 1.4; autonomy_aim parent = 0.8.
  ;  - value-rift amplifier (0.2 floor + the parent/child divergence) - an
  ;    OPAQUE belief op inside a (chance), rolled per victim at firing. When
  ;    value-rift becomes an explicit belief read it can fold back into the role.
  ; Cheap chances FIRST so they short-circuit.
  (when (and (chance (* (crime-scale) 0.0125
                        (- 1.0 (attr @self compassion))
                        (attr @self assertiveness)
                        (+ 1.0 (life-aim-aligns @self urge))))
             (chance (* 0.80
                        (+ 0.2 (value-rift @self ?victim))))))

  (effects
    ; Success = persuasiveness x deference x rift-term (the urged party's
    ; compassion defers, half again for one's own parent, capped; a value
    ; rift makes the demand land harder). The verb mints the urge clause in
    ; both minds, rolls this, and on success mints the urged state.
    (urge @self ?victim atone
          (* (mean2 (attr @self assertiveness) (attr @self politeness))
             (min 1 (* (attr ?victim compassion)
                       (if (believes {@self child ?victim}) 1.5 1.0)))
             (+ 0.3 (* 0.7 (value-rift @self ?victim)))))
    ))
