; ----------------------------------------------------------------------------
; Prototypes (Shape B toggles). Each is a (mint-band {@self prototype}
; <bool> [k prototype <proto>] 0.5): a single band at 0.5 IS a toggle (bool >= 0.5
; begins the kind, < 0.5 ends it), and mint-band's held-scan only matches the ONE
; declared kind, so a toggle never disturbs the other (non-@excl) prototype beliefs.
; Booleans compose as products of (believes)/(>=)/(<=) 0-or-1 terms; OR =
; (clamp (+ ...) 0 1). Gated on a PERSISTENT input band (plus the held prototype
; itself, for inputs like craving that can end) so the toggle can flip OFF when the
; condition lapses.
; ----------------------------------------------------------------------------

; drunkard: a standing craving for drink IS the dependency.
(npc-think classify_drunkard
  ; The drunkard toggle mints when a craving is present and REMOVES when it is forgotten
  ; (rehabilitation). The gate's prototype disjunct keeps the event eligible across the
  ; removing fire.
  (rng-stream behaviour)
  (role @self (or {@self craving ?}
                  {@self prototype [k prototype drunkard]}))
  (effects
    (mint-band {@self prototype} (prob {@self craving ?})
      [k prototype drunkard] 0.5)))

; nouveau_riche: high wealth (>= 0.60) carried by low breeding (<= 0.35).
(npc-think classify_nouveau_riche
  ; wealth re-derives annually; breeding is birth-seeded (an inert input, kept to document it).
  ; The toggle drops if wealth is retracted.
  (rng-stream behaviour)
  (role @self {@self wealth ?wealth, breeding ?breeding})
  (effects
    (mint-band {@self prototype}
      (* (>= ?wealth 0.60)
         (<= ?breeding 0.35))
      [k prototype nouveau_riche] 0.5)))

; self_made_man: rising trajectory + arrived class + low breeding + reputable.
(npc-think classify_self_made_man
  ; Toggle over the situation bands + repute (a Tier-2 sibling this reads);
  ; breeding is birth-seeded (inert). It drops when any input band toggles off.
  (rng-stream behaviour)
  (role @self {@self class_situation ?, breeding ?breeding})
  (effects
    (mint-band {@self prototype}
      (* (prob {@self social_trajectory [k social_trajectory rising]})
         (clamp (+ (prob {@self class_situation [k class_situation middle]})
                   (prob {@self class_situation [k class_situation upper]})) 0 1)
         (<= ?breeding 0.40)
         (clamp (+ (prob {@self repute [k repute exemplary]})
                   (prob {@self repute [k repute respectable]})) 0 1))
      [k prototype self_made_man] 0.5)))

; deserving_poor: poor/destitute + reputable.
(npc-think classify_deserving_poor
  (rng-stream behaviour)
  (role @self {@self economic_situation ?})
  (effects
    (mint-band {@self prototype}
      (* (clamp (+ (prob {@self economic_situation [k economic_situation poor]})
                   (prob {@self economic_situation [k economic_situation destitute]})) 0 1)
         (clamp (+ (prob {@self repute [k repute exemplary]})
                   (prob {@self repute [k repute respectable]})) 0 1))
      [k prototype deserving_poor] 0.5)))

; undeserving_poor: poor/destitute + disreputable.
(npc-think classify_undeserving_poor
  (rng-stream behaviour)
  (role @self {@self economic_situation ?})
  (effects
    (mint-band {@self prototype}
      (* (clamp (+ (prob {@self economic_situation [k economic_situation poor]})
                   (prob {@self economic_situation [k economic_situation destitute]})) 0 1)
         (clamp (+ (prob {@self repute [k repute disreputable]})
                   (prob {@self repute [k repute scandalous]})) 0 1))
      [k prototype undeserving_poor] 0.5)))

; go_between (the underworld fixer) - migrated from hsim_derive.cc is_go_between.
; NOT-reputable (neither exemplary nor respectable) + lower/middle class + the
; externalizing temperament to broker violence (the corrupt publican / fence /
; flash sporting-man). derive_prototypes READS this band to feed the C++
; contract-killing fixer pool. NB "disinhibition" here is the externalizing trait
; fold (low industriousness + low politeness + high volatility), the quantity the
; C++ used - NOT the (disinhibition) = 1 - inhibition macro.
(npc-think classify_go_between
  (rng-stream behaviour)
  (role @self {@self repute ?, class_situation ?})
  (effects
    (mint-band {@self prototype}
      (* (* (- 1 (prob {@self repute [k repute exemplary]}))
            (- 1 (prob {@self repute [k repute respectable]})))
         (clamp (+ (prob {@self class_situation [k class_situation lower]})
                   (prob {@self class_situation [k class_situation middle]})) 0 1)
         (>= (/ (+ (- 1 (attr @self industriousness))
                   (- 1 (attr @self politeness))
                   (attr @self volatility)) 3)
             0.50))
      [k prototype go_between] 0.5)))

; for_hire (migrated from hsim_derive.cc is_for_hire): CAPABILITY (a lethal skill
; OR raw brute strength) AND REASON (economic desperation OR a callous, disinhibited
; bad-seed). Split into a skilled path (role binds a martial / garrotting skill) and
; a MUTUALLY-EXCLUSIVE brute path (role excludes such a skill), so the two never
; clobber the shared for_hire toggle and a skill-loss hands the subject cleanly to
; the brute path. derive_prototypes reads the band for the contract-killing pool.
; "disinhibition" is the externalizing fold, as in classify_go_between.

; skilled path: a martial or garrotting skill IS the capability; mint on reason.
(npc-think classify_for_hire_skilled
  (rng-stream behaviour)
  (role @self {@self economic_situation ?}
              (or {@self skilled_in [k martial]}
                  {@self skilled_in [k garrotting]}))
  (effects
    (mint-band {@self prototype}
      ; REASON: economic desperation OR the callous + disinhibited bad seed.
      (clamp (+ (clamp (+ (prob {@self economic_situation [k economic_situation poor]})
                          (prob {@self economic_situation [k economic_situation destitute]})) 0 1)
                (* (<= (attr @self compassion) 0.40)
                   (>= (/ (+ (- 1 (attr @self industriousness))
                             (- 1 (attr @self politeness))
                             (attr @self volatility)) 3)
                       0.55))) 0 1)
      [k prototype for_hire] 0.5)))

; brute path: the lower-class strong man with NO lethal skill (footpad / cosh thug).
(npc-think classify_for_hire_brute
  (rng-stream behaviour)
  (role @self {@self economic_situation ?, class_situation ?}
              (not {@self skilled_in [k martial]})
              (not {@self skilled_in [k garrotting]}))
  (effects
    (mint-band {@self prototype}
      (* (>= (attr @self strength) 0.65)
         (prob {@self class_situation [k class_situation lower]})
         (clamp (+ (clamp (+ (prob {@self economic_situation [k economic_situation poor]})
                             (prob {@self economic_situation [k economic_situation destitute]})) 0 1)
                   (* (<= (attr @self compassion) 0.40)
                      (>= (/ (+ (- 1 (attr @self industriousness))
                                (- 1 (attr @self politeness))
                                (attr @self volatility)) 3)
                          0.55))) 0 1))
      [k prototype for_hire] 0.5)))
