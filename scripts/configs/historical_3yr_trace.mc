; ----------------------------------------------------------------------------
; historical_3yr_trace.mc - small-town 3-year config for binlog belief tracing.
; A 50-person town over 1700..1702: long enough to span the ~1-year default
; hsim salience window, so an orientation-minted org belief can be seen both
; minted (year 1) and forgotten (year 2) under --trace-all. Scratch config for
; the orientation memory-decay investigation; not part of the validation set.
; ----------------------------------------------------------------------------

(define-list config
  seeds 4242
  start 1700-01-01
  end 1702-12-31
  clock jump
  startup town-startup)
