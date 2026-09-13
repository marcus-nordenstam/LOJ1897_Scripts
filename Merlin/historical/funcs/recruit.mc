; ----------------------------------------------------------------------------
; open-job-for ?org ?jk - an OPEN job of ?org of kind ?jk, or @nothing: one whose ledger
; line names no holder. A seat somebody has been WRITTEN TO about is still open - a
; promise is a letter in the post, not a reservation, and the first man through the door
; is the one who gets it. The fact sits on the JOB, so the same test serves anyone
; reading the same seat.
; ----------------------------------------------------------------------------

(define-func open-job-for (?org ?jk)
  (bind @nothing ?found)
  (for-each ?rel (every {? org ?org})
    (bind ?rel.subject ?p)
    (if (and (is-a ?p ?jk)
             (any {?p job-id ?})
             (none {?p filled-by ?}))
      (then
        (bind ?p ?found)
        (break))))
  ?found)
