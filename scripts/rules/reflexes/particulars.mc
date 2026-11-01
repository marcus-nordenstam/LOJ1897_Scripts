; ----------------------------------------------------------------------------
; particulars (reflex) - a particular met is felt on its kind (funcs/particulars.mc): the drink
; @self took, the dish he ate, the book he read, the act the cause; and drink seen in another, a pet peeve, felt on
; its kind and then toward the drinker (rudeness, the other, is construe-speech's).
; ----------------------------------------------------------------------------

(reflex {@self DRINK ?drink /succ}:?DRINK
  (when (dirty-ended))
  (effects
    (any {?drink content-kind ?drink-kind})
    (if (substantial ?drink-kind)
        (then (meet-particular ?drink-kind ?DRINK)))))

(reflex {@self EAT ?food ?owner /succ}:?EAT
  (when (and (dirty-ended) (is-object ?food)))
  (effects
    (any {?food dish ?dish})
    (if (substantial ?dish)
        (then (meet-particular ?dish ?EAT)))))

(reflex {@self READ ?doc /succ}:?READ
  (when (and (dirty-ended) (is-a ?doc [k book])))
  (effects (meet-particular (kind ?doc) ?READ)))

(reflex {?drinker DRINK ?drink /ever}:?DRINK
  (when (and (dirty-born) (neq ?drinker @self)))
  (effects
    (any {?drink content-kind ?drink-kind})
    (if (and (substantial ?drink-kind) (is-a ?drink-kind [k alcoholic-drink]))
        (then (witness-peeve ?drinker [k alcoholic-drink] ?DRINK)))))
