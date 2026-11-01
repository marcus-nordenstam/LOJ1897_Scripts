; ----------------------------------------------------------------------------
; particulars (reflex) - a particular met is felt on its kind (funcs/particulars.mc): the drink
; @self took, the act it was taken in the cause.
; ----------------------------------------------------------------------------

(reflex {@self DRINK ?drink /succ}:?DRINK
  (when (dirty-ended))
  (effects
    (any {?drink content-kind ?drink-kind})
    (if (substantial ?drink-kind)
        (then (meet-particular ?drink-kind ?DRINK)))))
