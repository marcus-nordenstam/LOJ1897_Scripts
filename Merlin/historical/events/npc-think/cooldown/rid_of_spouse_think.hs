; ----------------------------------------------------------------------------
; rid_of_spouse.hs - instrumental homicide genesis: rid of a hated/abusive spouse.
;
; A cold instrumental branch of the affair-homicide family (siblings:
; crime_of_passion.hs, betrayal_kill.hs, clear_marriage.hs). An actor kills their
; spouse out of standing HATRED or ABUSE - to live in peace - independent of any
; lover, amplified by the spouse's ESTATE (the widow's portion pays for the
; childless) and by an UNMARRIAGEABLE lover waiting (the affair carries on into
; widowhood). A festering standing state, not a fresh grievance, so it carries its
; OWN misery gate (no rage gate).
;
; PURE .hs. The selection that run_generative_rid_of_spouse dispatched is spelled
; out here over composable ops:
;   - (role ?spouse ...) binds the actor's spouse;
;   - (when ...) is the misery gate (deep negative warmth - the detest band <= -2 -
;     OR the spouse's assault record against the actor) plus the propensity roll
;     (misery * (0.5+psychopathy) * disinhibition * (1-compassion) *
;     (1 + spouse-wealth) * unmarriageable-lover-mult, at the 0.02 base rate);
;   - (effects ...) mints {@self kill <spouse>} /caused_by-pinned to the held detest /
;     dislike belief, else the spouse-wealth belief ("kill <spouse> <- {@self detest
;     <spouse>}" or "... <- {<spouse> wealth 0.8}").
; attempt_harm then consumes the goal and executes a method as usual.
;
; Kept rare by design (the misery gate + base rate). To A/B, rename / remove this
; file (runtime-loaded; no rebuild).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think rid_of_spouse
  (cooldown 1 m)
  (rng-stream perpetration)

  (role @self 
              (adult @self))
  (role ?spouse (any_human ?spouse) {@self spouse ?spouse} (select (policy first-match)))

  ; The actor's lover, bound once (an unmarriageable - already-married - lover
  ; waiting raises the propensity). Bound at top-level so (is-married ?lover)
  ; below takes a plain ?var (a macro arg cannot carry an op-expr into a pattern).
  (any {@self lover}).target:?lover

  ; Misery gate (deep hatred OR abuse) + propensity. misery counts the two:
  ; hated = warmth band toward the spouse <= -2 (the detest band); abused = the
  ; spouse holds an assault record against the actor. propensity = misery *
  ; (0.5 + psychopathy) * (1 - inhibition) * (1 - compassion) *
  ; (1 + spouse-wealth) * (1.5 if an unmarriageable lover waits else 1.0).
  (when (and (or (detests ?spouse)
                 (any {?spouse assault @self /ever} (out int)))
             (chance
               (* (crime-scale) 0.02
                  (* (+ (if (detests ?spouse) (then 1) (else 0))
                        (if (any {?spouse assault @self /ever} (out int)) (then 1) (else 0)))
                     (* (+ 0.5 (attr @self psychopathy))
                        (* (disinhibition)
                           (* (callousness @self)
                              (* (+ 1 (any {?spouse wealth}).target)
                                 (if (is-married ?lover) (then 1.5) (else 1.0)))))))))))

  ; /caused_by: the held detest belief, else dislike, else the spouse-wealth belief.
  (effects
    (if (any {@self detest ?spouse} (out int))
        (then (begin-belief {@self detest ?spouse}): ?detest_bond
              (begin-goal {@self kill ?spouse} /caused_by ?detest_bond))
        (else (if (any {@self dislike ?spouse} (out int))
            (then (begin-belief {@self dislike ?spouse}): ?dislike_bond
                  (begin-goal {@self kill ?spouse} /caused_by ?dislike_bond))
            (else (any {?spouse wealth ?}).target: ?spouse_wealth
                  (begin-belief {?spouse wealth ?spouse_wealth}): ?wealth_bond
                  (begin-goal {@self kill ?spouse} /caused_by ?wealth_bond)))))))
