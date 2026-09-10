; ----------------------------------------------------------------------------
; open-job-for ?org ?jk - an OPEN job of ?org of kind ?jk, or @nothing: one whose ledger
; line names no holder AND carries no standing offer. The recruit officer's one test of
; whether an applicant can still be placed (resolve-applications). Both facts sit on the
; JOB, so the same test serves anyone reading the same seat.
; ----------------------------------------------------------------------------

(define-func open-job-for (?org ?jk)
  (bind @nothing ?found)
  (for-each ?rel (every {? org ?org})
    (bind ?rel.subject ?p)
    (if (and (is-a ?p ?jk)
             (any {?p job-ledger-line-no ?})
             (none {?p filled-by ?})
             (none {?p offered-to ?}))
      (then
        (bind ?p ?found)
        (break))))
  ?found)

; ----------------------------------------------------------------------------
; offered-job-for ?applicant - the job standing OFFERED to this man, or @nothing. The
; reverse read of {?job offered-to ?applicant}: the offer is a state of the SEAT, so
; asking it from the man's end is a walk, exactly as open-job-for walks an org's seats.
; ----------------------------------------------------------------------------

(define-func offered-job-for (?applicant)
  (bind @nothing ?found)
  (for-each ?rel (every {? offered-to ?applicant})
    (bind ?rel.subject ?p)
    (bind ?p ?found)
    (break))
  ?found)
