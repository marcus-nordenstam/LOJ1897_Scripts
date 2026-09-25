; ----------------------------------------------------------------------------
; historical_5yr.mc - 5-year test config for 4.13 phase validation.
; Mirrors historical.mc but with a 5-year span (1700..1704) for fast
; build/run/query validation cycles. Same seed + population so results are
; comparable to a full run's early years.
; ----------------------------------------------------------------------------

(define-list config
  seeds 4242
  start 1700-01-01
  end 1704-12-31
  clock jump
  startup town-startup)
