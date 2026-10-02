; ----------------------------------------------------------------------------
; predation.mc - appetitive homicide genesis (serial_predation).
;
; The first APPETITIVE generative kill motive: the reward is the killing itself
; (sadism / power), not inheritance, passion, a seat, or silencing a witness.
; Victims are chosen for a stable victim-TYPE (the predator's fixation) AND for
; SOCIAL INVISIBILITY (low class, stained repute = few defenders = mechanically
; safer). PURE .mc: no C++ generator, no C++ fixation op - the whole scan is
; role-casting over the predator's own acquaintance beliefs + belief-matching.
;
; hair-color / eye-color are (auto-percept) attrs (attrs.mon), so ANYONE who
; observes a person mirrors {?them hair-color X} / {?them eye-color Y} into their
; OWN beliefs - the physical look is knowable non-telepathically, exactly like
; the predator perceives it. No C++ attr backdoor.
;
; Two rules:
;   - seed-predation-profile: a latent predator (top lethal-disposition tail) with
;     no victim-type yet copies the PERCEIVED look (hair-color + eye-color) of a
;     random adult he knows into {@self fixation <trait-value>} beliefs, so
;     victim-type consistency emerges ("blond, blue-eyed"). One-shot.
;   - predation: role-casts a victim from the predator's OWN non-kin acquaintance
;     ties, HARD-filtered to his type via (overlapping-target {?victim hair-color}
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


; --- profile seeding (one-shot, precedes the first hunt) --------------------
(think seed-predation-profile
  (cooldown 1 m try-once)
  (rng-stream perpetration)
  (role @self {@self psychopathy ?psychopathy}
              {@self sadism ?sadism}
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
              -{@self fixation ?}
    ; A random adult the predator KNOWS the look of (has both perceived colour
    ; beliefs about), sampled by roulette - the victim-type prototype.
    (role ?proto {?proto isa [k human], condition [k alive]}
                 {?proto age-band [k young-adult|middle-aged|mature|elderly]}
                 (!= ?proto @self)
                 {?proto hair-color ?hair-color}
                 {?proto eye-color ?eye-color}
                 (select (score 1) (policy roulette))
      ; Only the hard lethal-disposition tail ever seeds (same floor as the hunt).
      (when (>= (* 0.5 (+ ?psychopathy ?sadism)) 0.65))
      (effects
        ; Copy the perceived look as the type signature (effect, so (target ...) is fine).
        (begin-belief {@self fixation ?hair-color})
        (begin-belief {@self fixation ?eye-color})))))

; --- the hunt ---------------------------------------------------------------
(think predation
  (cooldown 1 m try-once)
  (rng-stream perpetration)

  (role @self {@self psychopathy ?psychopathy}
              {@self sadism ?sadism}
              {@self inhibition ?inhibition}
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
              {@self fixation ?}

    ; The victim: cast from the predator's OWN non-kin acquaintance ties (his
    ; acquaintance graph, role-cast - no world scan), HARD-filtered to his type (the
    ; victim's hair OR eye colour is one of his fixations), then picked by social
    ; invisibility. ARGMAX (not roulette) so the maintained kill locks onto ONE stable
    ; target instead of re-rolling the victim every deliberation.
    (role ?victim {?victim isa [k human], condition [k alive]}
                  {@self spouse|fiancee|friend|lover|acquaintance|neighbour|enemy ?victim}
                  {?victim age-band [k young-adult|middle-aged|mature|elderly]}
                  (none {@self (kin-labels) ?victim})
                  ; TYPE FLOOR (cacheable non-@excl overlap): the victim carries one of
                  ; the predator's fixation values on hair-color OR eye-color.
                  (or (overlapping-target {?victim hair-color} {@self fixation})
                      (overlapping-target {?victim eye-color} {@self fixation}))
                  ; Invisibility score. Low class / stained repute = safer.
                  (select (score (+ 0.1
                                    (if {?victim class-situation [k class-situation lower]} (then 1.0) (else 0.0))
                                    (if {?victim repute [k repute disreputable]} (then 1.0) (else 0.0))
                                    (if {?victim repute [k repute scandalous]} (then 1.0) (else 0.0))))
                          (policy argmax))

      ; The REASON: the fixation (read as the /caused_by anchor, never re-minted - so the
      ; hunt fades if the fixation lifts). seed-predation-profile is what mints fixations.
      (bind (any {@self fixation ?}) ?fixation_bond)

      ; Disposition floor + rate. lethal = mean(psychopathy, sadism); propensity =
      ; (1 - inhibition) * lethal, DOUBLED for {@self life-aim power-aim}. The lethal tip
      ; fires ONCE then the running kill proposal latches it.
      (when (and (>= (* 0.5 (+ ?psychopathy ?sadism)) 0.65)
                 -{?victim condition [k dead]}
                 (or {@self kill ?victim}
                     (chance (* (crime-scale) 0.005
                                (* (* (- 1.0 ?inhibition) (* 0.5 (+ ?psychopathy ?sadism)))
                                   (if {@self life-aim [k power-aim]} (then 2.0) (else 1.0))))))))
      (declare-utility want)
      (effects
        (maintain-proposal {@self kill ?victim /caused_by ?fixation_bond})))))
