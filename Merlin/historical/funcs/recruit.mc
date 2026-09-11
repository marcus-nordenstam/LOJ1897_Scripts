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
             (any {?p job-id ?})
             (none {?p filled-by ?})
             (none {?p offered-to ?}))
      (then
        (bind ?p ?found)
        (break))))
  ?found)

; ----------------------------------------------------------------------------
; offeree-named ?name - the man of that NAME who holds a standing offer from anyone, or
; @nothing. The NAME is the join: an application is a piece of paper and the promise is a
; belief about a person, and the name written on the form is the only thing the two share
; - the same key the counter uses when the man himself finally turns up. Lets the officer
; tell the form he has just answered with an offer from the forms he must still refuse.
; ----------------------------------------------------------------------------

(define-func offeree-named (?name)
  (bind @nothing ?found)
  (for-each ?rel (every {? offered-to ?})
    (bind ?rel.target ?p)
    (if (any {?p name ?name})
      (then
        (bind ?p ?found)
        (break))))
  ?found)
