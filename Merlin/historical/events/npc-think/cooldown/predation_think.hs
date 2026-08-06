; ----------------------------------------------------------------------------
; predation.hs - appetitive homicide genesis (serial_predation).
;
; The first APPETITIVE generative kill motive: the reward is the killing itself
; (sadism / power), not inheritance, passion, a seat, or silencing a witness.
; Victims are chosen for a stable victim-TYPE (the predator's fixation) AND for
; SOCIAL INVISIBILITY (low class, stained repute = few defenders = mechanically
; safer). PURE .hs: no C++ generator, no C++ fixation op - the whole scan is
; role-casting over the predator's own acquaintance beliefs + belief-matching.
;
; hair_color / eye_color are (hsim-percept) attrs (common.arc), so ANYONE who
; observes a person mirrors {?them hair_color X} / {?them eye_color Y} into their
; OWN beliefs - the physical look is knowable non-telepathically, exactly like
; the predator perceives it. No C++ attr backdoor.
;
; Two events:
;   - seed_predation_profile: a latent predator (top lethal-disposition tail) with
;     no victim-type yet copies the PERCEIVED look (hair_color + eye_color) of a
;     random adult he knows into {@self fixation <trait-value>} beliefs, so
;     victim-type consistency emerges ("blond, blue-eyed"). One-shot.
;   - predation: role-casts a victim from the predator's OWN non-kin acquaintance
;     ties, HARD-filtered to his type via (overlapping-target {?victim hair_color}
;     {@self fixation}) (the non-@excl overlap op - the victim's hair OR eye colour
;     is one of the predator's fixations), then weighted-samples by SOCIAL
;     INVISIBILITY in the score (low class / stained repute = safer). (when ...)
;     gates the disposition floor + rate. Mints the kill goal + arms stalk_target.
;
; The type-match uses (overlapping-target ...) because fixation is non-@excl (a
; predator holds several fixation values); it is cacheable (see the classifier +
; cache_filter_match in hse_parser.cc / hse_engine.cc). The invisibility read lives
; in the (score ...), which is evaluated live per candidate (not cache-classified),
; so (target {?victim ...}) is fine there.
; Kept a tail by design (trait floor + base rate): 1-3 predators per few gens.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- profile seeding (one-shot, precedes the first hunt) --------------------
(npc-think seed_predation_profile
  (cooldown 1 m)
  (rng-stream perpetration)
  (role @self (adult @self)
              (not (believes {@self fixation ?})))
  ; A random adult the predator KNOWS the look of (has both perceived colour
  ; beliefs about), sampled by roulette - the victim-type prototype.
  (role ?proto (any_human ?proto)
               (adult ?proto)
               (not (= ?proto @self))
               (believes {?proto hair_color ?})
               (believes {?proto eye_color ?})
               (select (score 1) (policy roulette)))
  ; Only the hard lethal-disposition tail ever seeds (same floor as the hunt).
  (when (>= (lethal-disposition @self) 0.65))
  (effects
    ; Copy the perceived look as the type signature (effect, so (target ...) is fine).
    (begin-belief {@self fixation (target {?proto hair_color})})
    (begin-belief {@self fixation (target {?proto eye_color})})))

; --- the hunt ---------------------------------------------------------------
(npc-think predation
  (cooldown 1 m)
  (rng-stream perpetration)

  (role @self (adult @self)
              (believes {@self fixation ?}))

  ; The victim: cast from the predator's OWN non-kin acquaintance ties (his
  ; acquaintance graph, role-cast - no world scan), HARD-filtered to his type (the
  ; victim's hair OR eye colour is one of his fixations), then weighted-sampled by
  ; social invisibility (low class / stained repute = fewer defenders = safer).
  (role ?victim (any_human ?victim)
                (believes {@self spouse|fiancee|friend|lover|acquaintance|neighbour|enemy ?victim})
                (adult ?victim)
                (not (blood-kin @self ?victim))
                ; TYPE FLOOR (cacheable non-@excl overlap): the victim carries one of
                ; the predator's fixation values on hair_color OR eye_color.
                (or (overlapping-target {?victim hair_color} {@self fixation})
                    (overlapping-target {?victim eye_color} {@self fixation}))
                ; Invisibility score (live per-candidate; + a floor so a bare
                ; type-match is pickable). Low class / stained repute = safer.
                (select (score (+ 0.1
                                  (is-a (target {?victim class_situation}) [k class_situation lower])
                                  (is-a (target {?victim repute}) [k repute disreputable])
                                  (is-a (target {?victim repute}) [k repute scandalous])))
                        (policy roulette)))

  ; AFTER the select: disposition floor + rate. lethal = mean(psychopathy, sadism);
  ; propensity = (1 - inhibition) * lethal, DOUBLED for {@self life_aim power_aim}.
  (when (and (>= (lethal-disposition @self) 0.65)
             (believes {@self fixation ?fix})
             (chance (* (crime-scale) 0.005
                        (* (dark-propensity (lethal-disposition @self))
                           (if (believes {@self life_aim [k power_aim]}) (then 2.0) (else 1.0)))))))

  ; Mint the kill goal toward the resolved victim. /caused_by pins the first fixation
  ; belief (the gate's believes binds ?fix - a kind-valued feature - and the
  ; find-or-create reuses that exact belief; the appetitive signature the rap-sheet
  ; reads). mark-stalk arms the ~30-day surprise weight modifier attempt_harm reads.
  (effects
    (bind (begin-belief {@self fixation ?fix}) ?fixation_bond)
    (begin-goal {@self kill ?victim} /caused_by ?fixation_bond)
    (mark @self [k stalk_target] ?victim 30)))
