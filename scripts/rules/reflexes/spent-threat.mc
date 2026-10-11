; ----------------------------------------------------------------------------
; spent-threat - a threat carried out is spent: when an intent a held threat caused ends
; /succ, that threat ends with it.
; ----------------------------------------------------------------------------

(reflex {@self intent ? /succ}:?intent
  (effects
    (for-each ?threat (every {@self threaten ? ?})
      (if (has-cause ?intent ?threat)
          (then (end-belief ?threat))))))
