; ----------------------------------------------------------------------------
; lookup_tables.mc - small authored key->value maps, read via (table-match ...).
;
; These fold the old hardcoded C++ maps (the competence band ladder, the
; weekday work-hours label table) into (define-table) rows. Each is a scalar
; point-read: (table-match <table> <key-field> <key> <value-field> ?out).
; ----------------------------------------------------------------------------

; competence bands -> monotonic rank (novice 0 / trained 1 / expert 2). The
; unheld-skill default (-1) is supplied at the call site (competence-rank macro).
(define-table band_rank
  (fields band rank)
  (record [k competence-level novice]  0)
  (record [k competence-level trained] 1)
  (record [k competence-level expert]  2))

; weekday (1=Sun .. 7=Sat) -> the {job <label> start end} shift-belief label
; for today. Read with (time weekday) as the key.
(define-table weekday_hours_label
  (fields weekday label)
  (record 1 sun-hours)
  (record 2 mon-hours)
  (record 3 tue-hours)
  (record 4 wed-hours)
  (record 5 thu-hours)
  (record 6 fri-hours)
  (record 7 sat-hours))

