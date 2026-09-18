; ----------------------------------------------------------------------------
; duty_tables.hs - the duty model's authored data.
;
; org_duties: which duties an org KIND requires held. duty_review (duties_think.hs)
; walks these rows and applies every row whose kind the org is-a - so the base
; [k org] rows cover every org, and specific rows add per-kind duties on top.
; Behaviour dispatches on the HELD duty ({@self duty-to ?org [k <duty>]}), never
; on job kind or rank.
;
; level_rank: the level-rung ladder as a scalar (the seniority score component;
; head-ness is a job KIND, weighted separately in the argmax score).
; ----------------------------------------------------------------------------

; A duty is identified by the TASK it entails - a plain label symbol, NEVER a kind
; ([k <duty>] would force the task to be a noun-kind and load before this table). The
; held-duty belief {@self duty-to ?org <duty>} carries that symbol; behaviour dispatches
; on it by symbol equality (duties are flat - no sub-duty hierarchy to need is-a).
(define-table org_duties
  (fields kind duty)
  (record (kind [k org])           (duty dismiss_staff))
  (record (kind [k org])           (duty review_staff))
  (record (kind [k org])           (duty keep_records))
  (record (kind [k org])           (duty recruit-staff))
  (record (kind [k org household]) (duty provide_for))
  (record (kind [k org household]) (duty protect))
  (record (kind [k org church])    (duty officiate))
  (record (kind [k org club])      (duty admit_member)))

(define-table level_rank
  (fields level rank)
  (record (level [k trainee])    (rank 0))
  (record (level [k apprentice]) (rank 1))
  (record (level [k junior])     (rank 2))
  (record (level [k regular])    (rank 3))
  (record (level [k senior])     (rank 4)))
