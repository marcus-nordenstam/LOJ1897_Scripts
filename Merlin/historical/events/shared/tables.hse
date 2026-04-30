; ----------------------------------------------------------------------------
; Shared lookup tables. Pulled into events that reuse the same curve via:
;     (lookup <table-name> <key-expr>)
; ----------------------------------------------------------------------------

; Background per-year mortality curve, indexed by integer years-of-age.
; Folds in pre-industrial infant + child mortality at the low end.
(define-table mortality_by_age
  (age-bracket 0
    ((<  15)  0.006)
    ((<  40)  0.005)
    ((<  55)  0.010)
    ((<  65)  0.022)
    ((<  75)  0.050)
    ((<  85)  0.110)
    ((<  95)  0.220)
    (else     1.000)))
