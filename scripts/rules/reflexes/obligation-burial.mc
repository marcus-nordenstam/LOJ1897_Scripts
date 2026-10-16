; ----------------------------------------------------------------------------
; obligation-burial - a priest who learns of an unburied death owes the dead man his burial,
; grounded in his office; learning the body buried, by his own rite or another's, discharges it.
; ----------------------------------------------------------------------------

(reflex {?corpse condition [k dead]}
  (role ?office [k priest] {@self job ?office}
    (when (and {?corpse internment [k unburied]}
               (none {@self obligation {@self bury ?corpse} ?corpse})))
    (effects (begin-belief {@self obligation {@self bury ?corpse} ?corpse /caused_by ?office}))))

(reflex {?corpse internment [k buried]}
  (when {@self obligation {@self bury ?corpse} ?corpse})
  (effects (end-belief {@self obligation {@self bury ?corpse} ?corpse})))
