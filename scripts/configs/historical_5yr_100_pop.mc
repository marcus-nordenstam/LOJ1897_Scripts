; ----------------------------------------------------------------------------
; historical_5yr_200_pop.mc - 5-year validation config at FULL population (200).
; The release-iteration workhorse for behaviour + capacity validation at the
; population scale the canonical runs use (the 5yr default config runs a
; smaller founder set; this one exercises pool pressure and crowd dynamics).
; ----------------------------------------------------------------------------

(define-list config
  seeds 4242
  start 1700-01-01
  end 1704-12-31
  clock jump
  mwo "Merlin/bin/demo_tech_level_v2.mwo"
  startup town-startup)
