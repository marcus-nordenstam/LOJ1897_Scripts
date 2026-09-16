; ----------------------------------------------------------------------------
; historical_2yr.hs - 2-year validation config (1700-1701, ~50-person town). Long
; enough for a slow, single-purpose lane (churchgoing / building-discovery) to show
; multiple cycles; short enough for a fast release iteration. Mirrors the prior
; find-building baseline span so behaviour is directly comparable across the change.
; ----------------------------------------------------------------------------

(define-list config seed 4242 start_year 1700 end_year 1701 start_population 50)
