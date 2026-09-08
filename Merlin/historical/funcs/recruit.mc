; ----------------------------------------------------------------------------
; open-post-for ?org ?jk - an OPEN post of ?org of kind ?jk that @self has offered to
; nobody yet, or @nothing. The recruit officer's one test of whether an applicant can
; still be placed (resolve-applications).
; ----------------------------------------------------------------------------

(define-func open-post-for (?org ?jk)
  (bind @nothing ?found)
  (for-each ?rel (every {? org ?org})
    (bind ?rel.subject ?p)
    (if (and (is-a ?p ?jk)
             (any {?p post-no ?})
             (none {?p filled-by ?})
             (none {@self offered-post ? ?p}))
      (then
        (bind ?p ?found)
        (break))))
  ?found)
