; ----------------------------------------------------------------------------
; rouse (reflex, physiological) - the body wakes to what it feels. These fire even in an
; oblivious mind - the only reflexes that do - and (rouse) ends the act that took the mind
; (sleep) and wakes it; the deliberation at that same instant decides whether he stays up.
; ----------------------------------------------------------------------------

; The least pain that wakes a sleeper.
(define-macro rousing_pain () 0.1)

(reflex {@self pain ?p}
  (physiological)
  (when (>= ?p (rousing_pain)))
  (effects (rouse)))
