; ----------------------------------------------------------------------------
; particulars (reflex) - a particular met is felt on its kind (funcs/particulars.mc): the drink
; @self took, the book he read, the act the cause.
; ----------------------------------------------------------------------------

(reflex {@self DRINK ?drink /succ}:?DRINK
  (when (dirty-ended))
  (effects
    (any {?drink content-kind ?drink-kind})
    (if (substantial ?drink-kind)
        (then (meet-particular ?drink-kind ?DRINK)))))

(reflex {@self READ ?doc /succ}:?READ
  (when (and (dirty-ended) (is-a ?doc [k book])))
  (effects (meet-particular (kind ?doc) ?READ)))
