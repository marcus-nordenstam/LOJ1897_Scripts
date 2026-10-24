; ----------------------------------------------------------------------------
; lookup_tables.mc - small authored key->value maps, read via (table-match ...).
;
; These fold the old hardcoded C++ maps (the competence band ladder) into
; (define-table) rows. Each is a scalar
; point-read: (table-match <table> <key-field> <key> <value-field> ?out).
; ----------------------------------------------------------------------------

; competence bands -> monotonic rank (novice 0 / trained 1 / expert 2). The
; unheld-skill default (-1) is supplied at the call site (competence-rank macro).
(define-table band_rank
  (fields band rank)
  (record [k novice]  0)
  (record [k trained] 1)
  (record [k expert]  2))


