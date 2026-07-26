; ----------------------------------------------------------------------------
; duty_tables.hs - the duty model's authored data.
;
; org_duties: which duties an org KIND requires held. duty_review (duties_think.hs)
; walks these rows and applies every row whose kind the org is-a - so the base
; [k org] rows cover every org, and specific rows add per-kind duties on top.
; Behaviour dispatches on the HELD duty ({@self duty_to ?org [k <duty>]}), never
; on job kind or rank.
;
; level_rank: the level-rung ladder as a scalar (the seniority score component;
; head-ness is a job KIND, weighted separately in the argmax score).
; ----------------------------------------------------------------------------

(define-table org_duties
  (fields kind duty)
  (record (kind [k org])           (duty [k dismiss_staff]))
  (record (kind [k org])           (duty [k review_staff]))
  (record (kind [k org])           (duty [k keep_records]))
  (record (kind [k org household]) (duty [k recruit_staff]))
  (record (kind [k org household]) (duty [k provide_for]))
  (record (kind [k org household]) (duty [k protect]))
  (record (kind [k org church])    (duty [k officiate]))
  (record (kind [k org club])      (duty [k admit_member])))

(define-table level_rank
  (fields level rank)
  (record (level [k trainee])    (rank 0))
  (record (level [k apprentice]) (rank 1))
  (record (level [k junior])     (rank 2))
  (record (level [k regular])    (rank 3))
  (record (level [k senior])     (rank 4)))
