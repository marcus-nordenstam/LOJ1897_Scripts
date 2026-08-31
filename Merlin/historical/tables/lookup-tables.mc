; ----------------------------------------------------------------------------
; lookup_tables.hs - small authored key->value maps, read via (table-match ...).
;
; These fold the old hardcoded C++ maps (the competence band ladder, the
; weekday work-hours label table) into (define-table) rows. Each is a scalar
; point-read: (table-match <table> <key-field> <key> <value-field> ?out).
; ----------------------------------------------------------------------------

; competence bands -> monotonic rank (novice 0 / trained 1 / expert 2). The
; unheld-skill default (-1) is supplied at the call site (competence-rank macro).
(define-table band_rank
  (fields band rank)
  (record [k competence_level novice]  0)
  (record [k competence_level trained] 1)
  (record [k competence_level expert]  2))

; respectability bands -> monotonic rank (worst -> best). The unappraised
; default (-1) is supplied at the call site (repute-rank macro), so a trust
; post's req_repute gate fails a worker with NO proven band.
(define-table repute_rank
  (fields band rank)
  (record [k scandalous]   0)
  (record [k disreputable] 1)
  (record [k questionable] 2)
  (record [k respectable]  3)
  (record [k exemplary]    4))

; weekday index (0=Sun .. 6=Sat) -> the {job <label> start end} shift-belief label
; for today. Read with (now-weekday) as the key.
(define-table weekday_hours_label
  (fields weekday label)
  (record 0 sun_hours)
  (record 1 mon_hours)
  (record 2 tue_hours)
  (record 3 wed_hours)
  (record 4 thu_hours)
  (record 5 fri_hours)
  (record 6 sat_hours))

; job rank -> the prestige dimension it confers (0..1). rank is the level_rank
; rung (0 trainee .. 4 senior), 5 for headship of a non-household org, and -1
; for an NPC holding no job at all (the unemployed floor).
(define-table prestige_by_rank
  (fields rank prestige)
  (record -1 0.15)
  (record  0 0.20)
  (record  1 0.20)
  (record  2 0.30)
  (record  3 0.45)
  (record  4 0.65)
  (record  5 0.90))
