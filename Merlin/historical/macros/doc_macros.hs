; ----------------------------------------------------------------------------
; doc_macros.hs - readable named accessors over the generic document ops.
;
; These REPLACE the old C++ (org-founder ?a) / (articles-building ?a) value-ops.
; read-doc-record BINDS (the field flows out to the ?var), so a call is a binding
; conjunct - the bound var threads to later AND conjuncts and (through a when-gate)
; to (effects ...), exactly like (bind {...}). The articles kind is baked in here so
; call sites stay terse.
;
;   (org-founder ?articles ?f)      -> binds ?f = the org's founder
;   (articles-building ?articles ?b) -> binds ?b = the org's premises building
; ----------------------------------------------------------------------------

(define-macro org-founder (?doc ?f)
  (read-doc-record [k articles_of_incorporation] ?doc (founder ?f)))

(define-macro articles-building (?doc ?b)
  (read-doc-record [k articles_of_incorporation] ?doc (building ?b)))
