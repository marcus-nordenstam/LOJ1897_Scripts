; ----------------------------------------------------------------------------
; obliged-burial - a priest who learns of an unburied death is obliged to bury the body; learning
; it buried, by his own rite or another's, discharges the obligation.
; ----------------------------------------------------------------------------

(reflex {?corpse condition [k dead]}
  (when (and {@self job [k priest]}
             {?corpse internment [k unburied]}
             -{@self obliged ?corpse bury}))
  (effects (begin-belief {@self obliged ?corpse bury})))

(reflex {?corpse internment [k buried]}
  (when {@self obliged ?corpse bury})
  (effects (end-belief {@self obliged ?corpse bury})))
