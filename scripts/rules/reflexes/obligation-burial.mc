; ----------------------------------------------------------------------------
; obligation-burial - a priest who learns of an unburied death owes the dead man his burial,
; grounded in his office; learning the body buried, by his own rite or another's, discharges it.
; ----------------------------------------------------------------------------

(reflex {?corpse condition [k dead]}
  (when (and {@self job [k priest]}
             {?corpse internment [k unburied]}
             (none {@self obligation {@self bury ?corpse} ?corpse})))
  (effects
    (any {@self job [k priest]}): ?office
    (begin-belief {@self obligation {@self bury ?corpse} ?corpse /caused_by ?office})))

(reflex {?corpse internment [k buried]}
  (effects
    (for-each ?obligation (every {@self obligation {@self bury ?corpse} ?corpse})
      (end-belief ?obligation))))
