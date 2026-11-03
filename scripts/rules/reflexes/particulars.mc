; ----------------------------------------------------------------------------
; particulars (reflex) - a particular met (funcs/particulars.mc): the drink @self took, the dish he
; ate, the book he read, the act the cause; and another man seen drinking what @self holds an
; aversion to (a slight witnessed is reactions.mc's).
; ----------------------------------------------------------------------------

(reflex {@self DRINK ?fluid /succ}:?DRINK
  (when (dirty-ended))
  (effects (meet-particular (kind ?fluid) ?DRINK)))

(reflex {@self EAT ?food ?owner /succ}:?EAT
  (when (and (dirty-ended) (is-object ?food)))
  (effects
    (any {?food dish ?dish})
    (if (substantial ?dish)
        (then (meet-particular ?dish ?EAT)))))

(reflex {@self READ ?doc /succ}:?READ
  (when (and (dirty-ended) (is-a ?doc [k book])))
  (effects (meet-particular (kind ?doc) ?READ)))

(reflex {?drinker DRINK ?fluid /ever}:?DRINK
  (when (and (dirty-born) (neq ?drinker @self)))
  (effects (witness-aversion ?drinker (kind ?fluid) ?DRINK)))
