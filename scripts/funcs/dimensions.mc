; repute-fold - the seven-term mean the repute band-cut reads, for @self or ?other.
(define-func repute-fold (?who)
  (any {?who decorum ?decorum=0.65})
  (bind (count (every {?who lover ? /ever})) ?liaisons)
  (/ (+ (cond
          (case {?who honesty [k conduct-level good]} 0.85)
          (case {?who honesty [k conduct-level lax]}  0.25)
          (else 0.65))
        (cond
          (case {?who diligence [k conduct-level good]} 0.85)
          (case {?who diligence [k conduct-level lax]}  0.25)
          (else 0.65))
        (cond
          (case {?who generosity [k conduct-level good]} 0.85)
          (case {?who generosity [k conduct-level lax]}  0.25)
          (else 0.65))
        (cond
          (case {?who sobriety [k conduct-level good]} 0.85)
          (case {?who sobriety [k conduct-level lax]}  0.25)
          (else 0.65))
        (cond
          (case {?who devoutness [k piety-band devout]}  0.85)
          (case {?who devoutness [k piety-band secular]} 0.25)
          (else 0.65))
        ?decorum
        (- 0.85 (* (>= ?liaisons 1) 0.30)
                (* (>= ?liaisons 2) 0.30))) 7.0))

