; ----------------------------------------------------------------------------
; historical_10yr.hs - 10-year validation config for the single-evaluator pass.
; Mirrors historical_5yr.hs but with a 10-year span (1700..1709). Same seed +
; population so early years line up with the 5yr run.
; ----------------------------------------------------------------------------

(define-list config seed 4242 start_year 1700 end_year 1709 start_population 200)
