; ----------------------------------------------------------------------------
; Shared homeostat tunables. Authored once and pulled into every population-
; pressure event so a single edit re-tunes the whole feedback loop.
;
; Tables here are simple scalar lookups: the table body returns the same
; value regardless of key, used only as a way to bind a named constant
; through the (lookup ...) op. Future schedules will let us define plain
; (define-constant <name> <value>) - until then this idiom keeps things
; data-driven.
; ----------------------------------------------------------------------------

(define-table homeostat_target_population
  (age-bracket 0
    (else 200.0)))

(define-table homeostat_emigration_pressure
  (age-bracket 0
    (else 1.10)))

(define-table homeostat_immigration_pressure
  (age-bracket 0
    (else 0.90)))

; Emigration count must absorb births (~70/yr) + the bookkeeping minus
; deaths from disease/old-age (~40/yr together) to keep population from
; drifting. Underset emigration was the cause of 700 -> 1103 in 30 years
; in the prior sim run.
(define-table homeostat_emigration_count
  (age-bracket 0
    (else 50)))

(define-table homeostat_immigration_count
  (age-bracket 0
    (else 6)))
