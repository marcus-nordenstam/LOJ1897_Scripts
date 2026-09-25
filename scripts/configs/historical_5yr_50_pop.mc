; ----------------------------------------------------------------------------
; historical_5yr_50_pop.mc - 5-year validation config (1700-1704, ~50-person town).
; A 50-pop variant of the 5-year span: long enough to exercise the derived-signal
; cascade across several December re-derivations, small enough to avoid the 200-pop
; tell-flood t_sound overflow that historical_5yr.mc (200 pop) hits. Same seed as the
; 2-year config for directly comparable trajectories.
; ----------------------------------------------------------------------------

(define-list config
  seeds 4242
  start 1700-01-01
  end 1704-12-31
  clock jump
  startup town-startup)
