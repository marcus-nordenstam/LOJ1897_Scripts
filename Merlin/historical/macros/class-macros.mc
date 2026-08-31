; ----------------------------------------------------------------------------
; class_macros.hs - social-class rank reads over the {?who class-situation <band>}
; belief. Single-POV: (believes {?who ...}) reads the DELIBERATOR's OWN belief about
; ?who's class, never entering ?who's mind. class-situation is a Band-2 public
; standing fact (propagates to acquaintances), so an employer / founder reads a
; candidate's class from its own pool.
; ----------------------------------------------------------------------------

; (class-band ?who): the class rank the deliberator believes ?who holds -
; upper=2, middle=1, lower=0; unknown=-1 (an unknown class fails any positive floor).
(define-macro class-band (?who)
  (if {?who class-situation [k class-situation upper]}  (then 2)
  (else (if {?who class-situation [k class-situation middle]} (then 1)
      (else (if {?who class-situation [k class-situation lower]} (then 0)
          (else -1)))))))

; (class-rank-of ?floor): the rank of a class floor kind (the occupations / public_orgs
; class-floor field, an [k upper|middle|lower]). An unranked / lower floor is 0 (lowest).
(define-macro class-rank-of (?floor)
  (if (is-a ?floor [k class-situation upper])  (then 2)
  (else (if (is-a ?floor [k class-situation middle]) (then 1) (else 0)))))

; (class-at-least ?who ?floor): is ?who's believed class at least the ?floor kind in
; rank? An unknown class (-1) fails any floor.
(define-macro class-at-least (?who ?floor)
  (>= (class-band ?who) (class-rank-of ?floor)))
