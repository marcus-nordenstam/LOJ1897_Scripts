; (months-since-death ?c): whole months since THIS mind learned of ?c's death -
; the interval-start of @self's own ongoing {?c condition dead} belief. 0 when
; @self holds no such belief, or one with no known start (a body come upon, not seen
; dying). Observer-side and telepathy-honest by construction (only known deaths count);
; (time date) and the stored belief start count their months alike, so the month diff
; needs no alignment.
(define-func months-since-death (?c)
  (bind (start-time {?c condition [k dead]}) ?learned)
  (if (substantial ?learned)
      (then (max 0 (+ (* 12 (- (year (time date)) (year ?learned)))
                      (- (month (time date)) (month ?learned)))))
      (else 0)))
