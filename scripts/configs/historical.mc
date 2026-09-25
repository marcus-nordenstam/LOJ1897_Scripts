; ----------------------------------------------------------------------------
; historical.hsc - top-level config for the historical pre-sim.
; Only non-default values listed; defaults live in hsim_constants.h.
; ----------------------------------------------------------------------------

;(end_year          1897)

(define-list config
  seeds 4242
  start 1700-01-01
  end 1747-12-31
  clock jump
  startup town-startup)
