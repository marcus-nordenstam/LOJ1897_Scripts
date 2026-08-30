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
; Two rules:
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
; so (any {?victim ..}).target is fine there.
; Kept a tail by design (trait floor + base rate): 1-3 predators per few gens.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- profile seeding (one-shot, precedes the first hunt) --------------------
(npc-think seed_predation_profile
  (cooldown 1 m)
  (rng-stream perpetration)
  (role @self (adult @self)
              (none {@self fixation ?}))
  ; A random adult the predator KNOWS the look of (has both perceived colour
  ; beliefs about), sampled by roulette - the victim-type prototype.
  (role ?proto (any_human ?proto)
               (adult ?proto)
               (!= ?proto @self)
               {?proto hair_color ?}
               {?proto eye_color ?}
               (select (score 1) (policy roulette)))
  ; Only the hard lethal-disposition tail ever seeds (same floor as the hunt).
  (when (>= (lethal-disposition @self) 0.65))
  (effects
    ; Copy the perceived look as the type signature (effect, so (target ...) is fine).
    (begin-belief {@self fixation (any {?proto hair_color}).target})
    (begin-belief {@self fixation (any {?proto eye_color}).target})))

; --- the hunt ---------------------------------------------------------------
(npc-think predation
  (cooldown 1 m)
  (rng-stream perpetration)

  (role @self (adult @self)
              {@self fixation ?})

  ; The victim: cast from the predator's OWN non-kin acquaintance ties (his
  ; acquaintance graph, role-cast - no world scan), HARD-filtered to his type (the
  ; victim's hair OR eye colour is one of his fixations), then picked by social
  ; invisibility. ARGMAX (not roulette) so the maintained kill locks onto ONE stable
  ; target instead of re-rolling the victim every deliberation.
  (role ?victim (any_human ?victim)
                {@self spouse|fiancee|friend|lover|acquaintance|neighbour|enemy ?victim}
                (adult ?victim)
                (none (blood-kin @self ?victim))
                ; TYPE FLOOR (cacheable non-@excl overlap): the victim carries one of
                ; the predator's fixation values on hair_color OR eye_color.
                (or (overlapping-target {?victim hair_color} {@self fixation})
                    (overlapping-target {?victim eye_color} {@self fixation}))
                ; Invisibility score. Low class / stained repute = safer.
                (select (score (+ 0.1
                                  (is-a (any {?victim class_situation}).target [k class_situation lower])
                                  (is-a (any {?victim repute}).target [k repute disreputable])
                                  (is-a (any {?victim repute}).target [k repute scandalous])))
                        (policy argmax)))

  ; The REASON: the fixation (read as the /caused_by anchor, never re-minted - so the
  ; hunt fades if the fixation lifts). seed_predation_profile is what mints fixations.
  (any {@self fixation ?}):?fixation_bond

  ; Disposition floor + rate. lethal = mean(psychopathy, sadism); propensity =
  ; (1 - inhibition) * lethal, DOUBLED for {@self life_aim power_aim}. The lethal tip
  ; fires ONCE then the running kill proposal latches it.
  (when (and (>= (lethal-disposition @self) 0.65)
             (none {?victim condition [k dead]})
             (or (has-proposal {@self kill ?victim})
                 (chance (* (crime-scale) 0.005
                            (* (dark-propensity (lethal-disposition @self))
                               (if (any {@self life_aim [k power_aim]}) (then 2.0) (else 1.0))))))))
  (utility want)
  (effects
    (maintain-proposal {@self kill ?victim /caused_by ?fixation_bond})))
