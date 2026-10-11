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
;     random adult he knows into {@self hair-color-fixation ..} / {@self eye-color-fixation ..}
;     beliefs, so
;     victim-type consistency emerges ("blond, blue-eyed"). One-shot.
;   - predation: role-casts a victim from the predator's OWN non-kin acquaintance
;     ties, HARD-filtered to his type via (overlapping-target {?victim hair-color}
;     {@self hair-color-fixation}) (the non-@excl overlap op - the victim's hair colour
;     is his hair fixation OR his eye colour his eye fixation), then weighted-samples by SOCIAL
;     INVISIBILITY in the score (low class / stained repute = safer). (when ...)
;     gates the disposition floor + rate. Mints the kill goal + arms stalk_target.
;
; The type-match uses (overlapping-target ...) because a fixation is non-@excl (a
; predator may hold several values); it is cacheable (see the classifier +
; cache_filter_match in hse_parser.cc / hse_engine.cc). The invisibility read lives
; in the (score ...), which is evaluated live per candidate (not cache-classified),
; so (any {?victim ..}).target is fine there.
; Kept a tail by design (trait floor + base rate): 1-3 predators per few gens.
; ----------------------------------------------------------------------------


; --- the hunt ---------------------------------------------------------------
(intender predation
  (cooldown 1 m try-once)
  (rng-stream perpetration)

  (role @self {@self psychopathy ?psychopathy}
              {@self sadism ?sadism}
              {@self inhibition ?inhibition}
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
              {@self hair-color-fixation ?}

    ; The victim: cast from the predator's OWN non-kin acquaintance ties (his
    ; acquaintance graph, role-cast - no world scan), HARD-filtered to his type (the
    ; victim's hair colour is his hair fixation OR his eye colour his eye fixation), then
    ; picked by social
    ; invisibility. ARGMAX (not roulette) so the maintained kill locks onto ONE stable
    ; target instead of re-rolling the victim every deliberation.
    (role ?victim {?victim isa [k human], condition [k alive]}
                  {@self spouse|fiancee|friend|lover|acquaintance|neighbour|enemy ?victim}
                  {?victim age-band [k young-adult|middle-aged|mature|elderly]}
                  (none {@self (kin-labels) ?victim})
                  ; TYPE FLOOR (cacheable non-@excl overlap): the victim's hair is the
                  ; predator's hair fixation OR the victim's eyes his eye fixation.
                  (or (overlapping-target {?victim hair-color} {@self hair-color-fixation})
                      (overlapping-target {?victim eye-color} {@self eye-color-fixation}))
                  ; Invisibility score. Low class / stained repute = safer.
                  (select (score (+ 0.1
                                    (if {?victim class-situation [k lower]} (then 1.0) (else 0.0))
                                    (if {?victim repute [k disreputable]} (then 1.0) (else 0.0))
                                    (if {?victim repute [k scandalous]} (then 1.0) (else 0.0))))
                          (policy argmax))

      ; The REASON: the fixation (read as the /caused_by anchor, never re-minted - so the
      ; hunt fades if the fixation lifts). seed-predation-profile is what mints fixations.
      (bind (any {@self hair-color-fixation ?}) ?fixation_bond)

      ; Disposition floor + rate. lethal = mean(psychopathy, sadism); propensity =
      ; (1 - inhibition) * lethal, DOUBLED for {@self life-aim power-aim}. The lethal tip
      ; fires ONCE then the latch holds it.
      (when (and (>= (* 0.5 (+ ?psychopathy ?sadism)) 0.65)
                 -{?victim condition [k dead]}
                 (latch-eval (chance (* (crime-scale) 0.005
                                (* (* (- 1.0 ?inhibition) (* 0.5 (+ ?psychopathy ?sadism)))
                                   (if {@self life-aim [k power-aim]} (then 2.0) (else 1.0))))))))
      (declare-utility want)
      (effects
        (maintain-intent {@self intent {@self kill ?victim}} /caused_by ?fixation_bond)))))
