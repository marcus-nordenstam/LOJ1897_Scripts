; ----------------------------------------------------------------------------
; Prototypes (Shape B toggles). Each is a (mint-band {@self prototype}
; <bool> [k prototype <proto>] 0.5): a single band at 0.5 IS a toggle (bool >= 0.5
; begins the kind, < 0.5 ends it), and mint-band's held-scan only matches the ONE
; declared kind, so a toggle never disturbs the other (non-@excl) prototype beliefs.
; Booleans compose as products of (believes)/(>=)/(<=) 0-or-1 terms; OR =
; (clamp (+ ...) 0 1). Gated on a PERSISTENT input band so the event stays
; on-agenda to toggle OFF when the condition lapses; drunkard's input (craving) can
; end, so it also stays on-agenda while the prototype itself is held.
; ----------------------------------------------------------------------------

; drunkard: a standing craving for drink IS the dependency.
(npc-think classify_drunkard
  ; on-changed on craving: the drunkard toggle mints when a craving forms and REMOVES when it
  ; is forgotten (rehabilitation) - the forget edge is what on-commit would miss. The gate's
  ; prototype disjunct keeps the event eligible across the removing fire.
  (schedule on-changed {@self craving ?})
  (if-blocked hold)
  (rng-stream behaviour)
  (role @self (or (believes {@self craving ?})
                  (believes {@self prototype [k prototype drunkard]})))
  (effects
    (mint-band {@self prototype} (believes {@self craving ?})
      [k prototype drunkard] 0.5)))

; nouveau_riche: high wealth (>= 0.60) carried by low breeding (<= 0.35).
(npc-think classify_nouveau_riche
  ; wealth re-derives annually (the toggle flip); breeding is birth-seeded (inert trigger,
  ; kept to document the input). on-changed so the toggle also drops if wealth is retracted.
  (schedule on-changed {@self wealth ?} {@self breeding ?})
  (if-blocked hold)
  (rng-stream behaviour)
  (role @self (believes {@self wealth ?}))
  (effects
    (mint-band {@self prototype}
      (* (>= (target {@self wealth}) 0.60)
         (<= (target {@self breeding}) 0.35))
      [k prototype nouveau_riche] 0.5)))

; self_made_man: rising trajectory + arrived class + low breeding + reputable.
(npc-think classify_self_made_man
  ; Toggle over the situation bands + respectability_situation (a Tier-2 sibling this reads);
  ; breeding is birth-seeded (inert). on-changed so it drops when any band toggles off.
  (schedule on-changed {@self social_trajectory ?} {@self class_situation ?}
                       {@self breeding ?} {@self respectability_situation ?})
  (if-blocked hold)
  (rng-stream behaviour)
  (role @self (believes {@self class_situation ?}))
  (effects
    (mint-band {@self prototype}
      (* (believes {@self social_trajectory [k social_trajectory rising]})
         (clamp (+ (believes {@self class_situation [k class_situation middle]})
                   (believes {@self class_situation [k class_situation upper]})) 0 1)
         (<= (target {@self breeding}) 0.40)
         (clamp (+ (believes {@self respectability_situation [k respectability_situation exemplary]})
                   (believes {@self respectability_situation [k respectability_situation respectable]})) 0 1))
      [k prototype self_made_man] 0.5)))

; deserving_poor: poor/destitute + reputable.
(npc-think classify_deserving_poor
  (schedule on-changed {@self economic_situation ?} {@self respectability_situation ?})
  (if-blocked hold)
  (rng-stream behaviour)
  (role @self (believes {@self economic_situation ?}))
  (effects
    (mint-band {@self prototype}
      (* (clamp (+ (believes {@self economic_situation [k economic_situation poor]})
                   (believes {@self economic_situation [k economic_situation destitute]})) 0 1)
         (clamp (+ (believes {@self respectability_situation [k respectability_situation exemplary]})
                   (believes {@self respectability_situation [k respectability_situation respectable]})) 0 1))
      [k prototype deserving_poor] 0.5)))

; undeserving_poor: poor/destitute + disreputable.
(npc-think classify_undeserving_poor
  (schedule on-changed {@self economic_situation ?} {@self respectability_situation ?})
  (if-blocked hold)
  (rng-stream behaviour)
  (role @self (believes {@self economic_situation ?}))
  (effects
    (mint-band {@self prototype}
      (* (clamp (+ (believes {@self economic_situation [k economic_situation poor]})
                   (believes {@self economic_situation [k economic_situation destitute]})) 0 1)
         (clamp (+ (believes {@self respectability_situation [k respectability_situation disreputable]})
                   (believes {@self respectability_situation [k respectability_situation scandalous]})) 0 1))
      [k prototype undeserving_poor] 0.5)))
