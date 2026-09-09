; ----------------------------------------------------------------------------
; open-job-for ?org ?jk - an OPEN job of ?org of kind ?jk that @self has offered to
; nobody yet, or @nothing. The recruit officer's one test of whether an applicant can
; still be placed (resolve-applications). A job is a LEDGER LINE, so it is open when its
; line names no holder and no standing offer is out on it.
; ----------------------------------------------------------------------------

(define-func open-job-for (?org ?jk)
  (bind @nothing ?found)
  (for-each ?rel (every {? org ?org})
    (bind ?rel.subject ?p)
    (if (and (is-a ?p ?jk)
             (any {?p job-ledger-line-no ?})
             (none {?p filled-by ?})
             (none {@self offered-post ? ?p}))
      (then
        (bind ?p ?found)
        (break))))
  ?found)
