; ----------------------------------------------------------------------------
; withhold-lifts (reflex) - a man who would not tell @self something did so at how close they were:
; once @self holds him a friend or closer, what he withheld may be asked of him again.
; ----------------------------------------------------------------------------

(reflex {@self (closeness-labels friend) ?who}:?bond
  (when (and (dirty-born) (neq ?who @self)))
  (effects
    (for-each ?withheld (every {?who withhold ? @self})
      (end-belief ?withheld))))
