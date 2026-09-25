; ----------------------------------------------------------------------------
; historical_2yr.mc - 2-year validation config (1700-1701, ~50-person town). Long
; enough for a slow, single-purpose aspect (churchgoing / building-discovery) to show
; multiple cycles; short enough for a fast release iteration. Mirrors the prior
; find-building baseline span so behaviour is directly comparable across the change.
; ----------------------------------------------------------------------------

(define-list config
  seeds 4242
  start 1700-01-01
  end 1701-12-31
  clock jump
  startup town-startup)
