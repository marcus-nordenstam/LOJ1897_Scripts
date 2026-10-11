; ----------------------------------------------------------------------------
; spent-grievance - a crime done on a grievance's behalf spends it: when an intent to expose,
; humiliate, coerce, seduce or bribe a man ends /succ, the pressures that caused it are released
; (spend-grievance, funcs/grievance.mc).
; ----------------------------------------------------------------------------

(reflex {@self intent {@self expose|humiliate|coerce|seduce|bribe ?target} /succ}:?intent
  (effects (spend-grievance ?intent)))
