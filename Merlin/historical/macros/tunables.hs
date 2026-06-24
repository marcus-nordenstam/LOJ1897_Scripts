; ----------------------------------------------------------------------------
; tunables.hs - shared curves + tunable constants, as macros.
;
; These were formerly (define-table ...) + (lookup ...) named expressions; they
; are just named formulas / constants, so they are macros now. A curve takes its
; input as a real parameter; a constant takes none. Edit once, re-tunes every
; event that calls it.
; ----------------------------------------------------------------------------

; Background per-year mortality curve: integer years-of-age -> death probability.
; Folds in pre-industrial infant + child mortality at the low end.
(define-macro mortality_by_age (?age)
  (age-bracket ?age
    ((<  15)  0.006)
    ((<  40)  0.005)
    ((<  55)  0.010)
    ((<  65)  0.022)
    ((<  75)  0.050)
    ((<  85)  0.110)
    ((<  95)  0.220)
    (else     1.000)))

; Population homeostat tunables (constants). Emigration count must absorb births
; (~70/yr) minus disease/old-age deaths (~40/yr) to keep population from drifting.
(define-macro homeostat_target_population   () 200.0)
(define-macro homeostat_emigration_pressure () 1.10)
(define-macro homeostat_immigration_pressure () 0.90)
(define-macro homeostat_emigration_count    () 50)
(define-macro homeostat_immigration_count   () 6)
