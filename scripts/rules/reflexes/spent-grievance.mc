; ----------------------------------------------------------------------------
; spent-grievance - a crime done on a grievance's behalf spends it: when an intent to expose,
; humiliate, coerce, seduce, bribe or report a man ends /succ, every pressure toward him that caused
; it is released by 0.75 of its remaining salience.
; ----------------------------------------------------------------------------

(reflex {@self intent {@self expose|humiliate|coerce|seduce|bribe|report-crime ?target} /succ}:?intent
  (effects
    (for-each ?pressure (every {@self pressure ? ?})
      (if (has-cause ?intent ?pressure)
          (then (discharge-pressure ?pressure 0.75))))))
