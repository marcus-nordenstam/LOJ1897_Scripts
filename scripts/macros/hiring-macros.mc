; ----------------------------------------------------------------------------
; hiring_macros.mc - the eligibility gates + match score of the hiring
; (select-row ...) in hire_errand_act.mc, composing over the occupations
; table's row fields (the old C++ occupation_match / best_match_job, ported).
; Every gate reads @self's OWN beliefs / attrs - telepathy-honest by construction.
; `none` is the table's absent-field sentinel; each gate passes when its
; requirement is unauthored.
; ----------------------------------------------------------------------------

; respectability bands -> monotonic rank (worst -> best). The unappraised
; default (-1) is supplied at the call site (repute-rank macro), so a trust
; post's req-repute gate fails a worker with NO proven band.
(define-table repute_rank
  (fields band rank)
  (record [k scandalous]   0)
  (record [k disreputable] 1)
  (record [k questionable] 2)
  (record [k respectable]  3)
  (record [k exemplary]    4))







