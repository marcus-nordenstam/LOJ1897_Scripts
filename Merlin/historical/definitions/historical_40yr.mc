; ----------------------------------------------------------------------------
; historical_40yr.hs - 40-year test config (1700..1739). Same seed + population
; as the 5yr/20yr configs so the early years are comparable; long enough to see
; org-set stability, founder coverage, and per-year sim cost as population grows.
; ----------------------------------------------------------------------------

(define-list config seed 4242 start_year 1700 end_year 1739 start_population 200)
