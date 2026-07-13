; ----------------------------------------------------------------------------
; hiring_macros.hs - the eligibility gates + match score of the hiring
; (select-record ...) in hire_errand_act.hs, composing over the occupations
; table's row fields (the old C++ occupation_match / best_match_job, ported).
; Every gate reads @self's OWN beliefs / attrs - telepathy-honest by construction.
; `none` is the table's absent-field sentinel; each gate passes when its
; requirement is unauthored.
; ----------------------------------------------------------------------------

; (repute-rank ?band): monotonic rank of a respectability band (scandalous 0 ..
; exemplary 4); -1 when unappraised/@fail - so a req_repute gate FAILS a worker
; with no proven band (a trust post needs a proven name).
(define-macro repute-rank (?band)
  (lookup repute_rank band ?band rank -1))

; (hosted-by ?bt ?org-kind): does an org of ?org-kind host this post? A `none`
; business_type is a generic post (a cook / clerk works anywhere).
(define-macro hosted-by (?bt ?org-kind)
  (or (= ?bt none) (is-a ?org-kind ?bt)))

; (class-ok ?w ?cf): the class floor. An UNAPPRAISED class passes (matching the
; old match's "unappraised passes" rule); a known class must meet the floor.
(define-macro class-ok (?w ?cf)
  (or (not (believes {?w class_situation ?}))
      (class-at-least ?w ?cf)))

; (repute-ok ?w ?rr): the reputation gate. `none` = no requirement; otherwise
; the worker's PROVEN band must rank at or above it (unappraised = -1 = fail).
(define-macro repute-ok (?w ?rr)
  (or (= ?rr none)
      (>= (repute-rank (situation ?w repute)) (repute-rank ?rr))))

; (skill-ok ?w ?d ?b): the skill/education gate. `none` = no requirement (an
; entry rung); otherwise the worker's own {@self skilled_in <domain> /aux <band>}
; must hold at >= the required band (unheld = -1 = fail).
(define-macro skill-ok (?w ?d ?b)
  (or (= ?d none)
      (>= (competence-rank (auxiliary {?w skilled_in ?d}))
          (competence-rank ?b))))

; (job-match-score ?t1 ?w1 ?t2 ?w2): the soft match score - a base so any
; eligible candidate is hirable, plus the weighted preferred-trait reads. Also
; the ACCEPTANCE probability at the interview ((chance (min 0.95 score)) - a
; marginal fit may not be taken this time).
(define-macro job-match-score (?t1 ?w1 ?t2 ?w2)
  (+ 0.1
     (if (= ?t1 none) 0 (* ?w1 (attr @self ?t1)))
     (if (= ?t2 none) 0 (* ?w2 (attr @self ?t2)))))
