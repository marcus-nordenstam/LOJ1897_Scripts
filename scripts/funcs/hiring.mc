; (job-seeker ?w ?age): the WORKER-side eligibility to hunt for waged work - working age,
; not disgraced, and not rich enough to live without a wage. The wealth leg reads as
; "needs work" for a seeker with no wealth belief yet (the inner (and ..) is false).
; Shared by the two job_search pre-commit cases (head to a known board / search for one).
(define-func job-seeker (?w ?age)
  (any {?w repute ?repute=@nothing})
  (and (>= ?age 16)
       (<= ?age 55)
       (!= ?repute [k scandalous])
       (not (and (any {?w wealth ?wl}) (>= ?wl (seek_job_wealth_ceiling))))))
