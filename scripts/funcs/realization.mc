; (months-since-death ?c): whole months since THIS mind learned of ?c's death -
; the interval-start of @self's own ongoing {?c condition dead} belief. 0 when
; @self holds no such belief. Observer-side and telepathy-honest by construction
; (only known deaths count); (time date) and the stored belief start count their
; months alike, so the month diff needs no alignment.
(define-func months-since-death (?c)
  (if {?c condition [k dead]}
      (then (max 0 (+ (* 12 (- (year (time date))
                         (year (start-time {?c condition [k dead]}))))
                (- (month (time date))
                   (month (start-time {?c condition [k dead]}))))))
      (else 0)))
