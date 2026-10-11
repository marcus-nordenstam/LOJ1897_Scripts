; ----------------------------------------------------------------------------
; obligation-burial - a priest who learns of an unburied death owes the dead man his burial,
; grounded in his office; learning the body buried, by his own rite or another's, discharges it.
; ----------------------------------------------------------------------------

(reflex {?corpse condition [k dead]}
  (effects
    (any {@self job [k priest]}): ?office
    (if (and (substantial ?office)
             {?corpse internment [k unburied]}
             (none {@self obligation {@self bury ?corpse} ?corpse}))
        (then (begin-belief {@self obligation {@self bury ?corpse} ?corpse /caused_by ?office})))))

(reflex {?corpse internment [k buried]}
  (effects
    (any {@self obligation {@self bury ?corpse} ?corpse}): ?obligation
    (if (substantial ?obligation)
        (then (end-belief ?obligation)))))
