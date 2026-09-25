; ----------------------------------------------------------------------------
; historical_10yr.mc - 10-year validation config for the single-evaluator pass.
; Mirrors historical_5yr.mc but with a 10-year span (1700..1709). Same seed +
; population so early years line up with the 5yr run.
; ----------------------------------------------------------------------------

(define-list config
  seeds 4242
  start 1700-01-01
  end 1709-12-31
  clock jump
  mwo "Merlin/bin/demo_tech_level_v2.mwo"
  startup town-startup)
