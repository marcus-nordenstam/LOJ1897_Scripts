; ----------------------------------------------------------------------------
; occupation_shifts.hs - authored working hours per job, as config rows read by
; the C++ (stamp-work-hours ...) backend via the generic table reader
; (hse_table_for_each_row) - the old t_work_shift/t_work_day structs + the am/pm
; parse are gone. At hire, one {<job_obj> <weekday>_hours <start> <end>} belief
; is minted per row of the assigned shift (target = start hour, aux = end hour).
;
;   job       - the job kind [k job <leaf>], or the bare atom `default`: the
;               schedule for every job with NO authored rows (Mon-Sat 9-17).
;   shift_id  - groups a shift's days. A job with rows under MORE than one
;               shift_id (nurse / factory_worker: day AND night) has the worker
;               assigned exactly ONE shift_id by rng at hire.
;   day_label - the weekday_hours belief label (sun_hours .. sat_hours, matching
;               the weekday_hours_label table). A weekday with no row = a day off.
;   start_h / end_h - 24h clock hours; start > end wraps past midnight (a night
;               shift, e.g. 19 -> 7).
; ----------------------------------------------------------------------------

(define-table occupation_shifts
  (fields job shift_id day_label start_h end_h)

  ;; the default working week (any job without authored rows): Mon-Sat 9-17
  (record default 0 mon_hours 9 17)
  (record default 0 tue_hours 9 17)
  (record default 0 wed_hours 9 17)
  (record default 0 thu_hours 9 17)
  (record default 0 fri_hours 9 17)
  (record default 0 sat_hours 9 17)

  ;; priest: irregular week - Sunday IS the working day; omitted days are off
  (record [k job priest] 0 sun_hours 8 13)
  (record [k job priest] 0 wed_hours 10 12)
  (record [k job priest] 0 sat_hours 16 18)

  ;; nurse: the hospital runs round the clock - a day shift and a night shift
  (record [k job nurse] 0 mon_hours 7 19)
  (record [k job nurse] 0 tue_hours 7 19)
  (record [k job nurse] 0 wed_hours 7 19)
  (record [k job nurse] 0 thu_hours 7 19)
  (record [k job nurse] 0 fri_hours 7 19)
  (record [k job nurse] 0 sat_hours 7 19)
  (record [k job nurse] 0 sun_hours 7 19)
  (record [k job nurse] 1 mon_hours 19 7)
  (record [k job nurse] 1 tue_hours 19 7)
  (record [k job nurse] 1 wed_hours 19 7)
  (record [k job nurse] 1 thu_hours 19 7)
  (record [k job nurse] 1 fri_hours 19 7)
  (record [k job nurse] 1 sat_hours 19 7)
  (record [k job nurse] 1 sun_hours 19 7)

  ;; factory_worker: day AND night shifts; a hand is assigned one at hire
  (record [k job factory_worker] 0 mon_hours 6 18)
  (record [k job factory_worker] 0 tue_hours 6 18)
  (record [k job factory_worker] 0 wed_hours 6 18)
  (record [k job factory_worker] 0 thu_hours 6 18)
  (record [k job factory_worker] 0 fri_hours 6 18)
  (record [k job factory_worker] 0 sat_hours 6 18)
  (record [k job factory_worker] 1 mon_hours 18 6)
  (record [k job factory_worker] 1 tue_hours 18 6)
  (record [k job factory_worker] 1 wed_hours 18 6)
  (record [k job factory_worker] 1 thu_hours 18 6)
  (record [k job factory_worker] 1 fri_hours 18 6)
  (record [k job factory_worker] 1 sat_hours 18 6))
