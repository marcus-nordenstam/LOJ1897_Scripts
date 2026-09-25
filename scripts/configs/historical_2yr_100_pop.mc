; ----------------------------------------------------------------------------
; historical_2yr_100_pop.mc - 2-year validation config at 100 population
; (1700-1701, seed 4242). Baseline/comparison config for the labour-market
; reimplementation: long enough for the hiring pipeline to cycle, at a population
; that founds orgs and exercises the labour market.
; ----------------------------------------------------------------------------

(define-list config
  seeds 4242
  start 1700-01-01
  end 1701-12-31
  clock jump
  startup town-startup)
