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

; Belief reads, NOT doc scans (reasoning is from beliefs). The caller passes the
; articles doc ?art (a goal focus or a {?org record ?art} bind); these recover the
; org OBJECT off the reader's own {?org record ?art} belief, then read the org's
; constitutive founder / workplace belief. Names kept for call-site continuity.
(define-macro org-founder (?art ?f)
  (and (any {?art_org record ?art})
       {?art_org founder ?f}))

(define-macro articles-building (?art ?wp)
  (and (any {?art_org record ?art})
       {?art_org workplace ?wp}))
