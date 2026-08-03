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
  (role @self (or (believes {@self craving ?})
                  (believes {@self prototype [k prototype drunkard]})))
  (effects
    (mint-band {@self prototype} (believes {@self craving ?})
      [k prototype drunkard] 0.5)))

; nouveau_riche: high wealth (>= 0.60) carried by low breeding (<= 0.35).
(npc-think classify_nouveau_riche
  ; wealth re-derives annually; breeding is birth-seeded (an inert input, kept to document it).
  ; The toggle drops if wealth is retracted.
  (rng-stream behaviour)
  (role @self (believes {@self wealth ?wealth, breeding ?breeding}))
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
  (role @self (believes {@self class_situation ?, breeding ?breeding}))
  (effects
    (mint-band {@self prototype}
      (* (believes {@self social_trajectory [k social_trajectory rising]})
         (clamp (+ (believes {@self class_situation [k class_situation middle]})
                   (believes {@self class_situation [k class_situation upper]})) 0 1)
         (<= ?breeding 0.40)
         (clamp (+ (believes {@self repute [k repute exemplary]})
                   (believes {@self repute [k repute respectable]})) 0 1))
      [k prototype self_made_man] 0.5)))

; deserving_poor: poor/destitute + reputable.
(npc-think classify_deserving_poor
  (rng-stream behaviour)
  (role @self (believes {@self economic_situation ?}))
  (effects
    (mint-band {@self prototype}
      (* (clamp (+ (believes {@self economic_situation [k economic_situation poor]})
                   (believes {@self economic_situation [k economic_situation destitute]})) 0 1)
         (clamp (+ (believes {@self repute [k repute exemplary]})
                   (believes {@self repute [k repute respectable]})) 0 1))
      [k prototype deserving_poor] 0.5)))

; undeserving_poor: poor/destitute + disreputable.
(npc-think classify_undeserving_poor
  (rng-stream behaviour)
  (role @self (believes {@self economic_situation ?}))
  (effects
    (mint-band {@self prototype}
      (* (clamp (+ (believes {@self economic_situation [k economic_situation poor]})
                   (believes {@self economic_situation [k economic_situation destitute]})) 0 1)
         (clamp (+ (believes {@self repute [k repute disreputable]})
                   (believes {@self repute [k repute scandalous]})) 0 1))
      [k prototype undeserving_poor] 0.5)))
