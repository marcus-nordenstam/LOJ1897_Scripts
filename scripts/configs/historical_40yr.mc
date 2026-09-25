; ----------------------------------------------------------------------------
; historical_40yr.mc - 40-year test config (1700..1739). Same seed + population
; as the 5yr/20yr configs so the early years are comparable; long enough to see
; org-set stability, founder coverage, and per-year sim cost as population grows.
; ----------------------------------------------------------------------------

(define-list config
  seeds 4242
  start 1700-01-01
  end 1739-12-31
  clock jump
  startup town-startup)
