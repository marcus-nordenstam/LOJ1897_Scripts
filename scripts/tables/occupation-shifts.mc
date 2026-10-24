; ----------------------------------------------------------------------------
; occupation_shifts.mc - authored working hours per job. At hire, one
; {<job_obj> working-hours <weekly interval>} belief is minted per row of the assigned shift.
;
;   job           - the job kind [k job <leaf>], or [k job] itself: the
;                   schedule for every job with NO authored rows (Mon-Sat 9-17).
;   shift-id      - groups a shift's rows. A job with rows under MORE than one
;                   shift-id (nurse / factory-worker: day AND night) has the worker
;                   assigned exactly ONE shift-id by rng at hire.
;   working-hours - a weekly interval, from its first clock until its second; days whose
;                   hours differ are one row each. An end before the start wraps past
;                   midnight (a night shift).
; ----------------------------------------------------------------------------

(define-table occupation_shifts
  (fields job shift-id working-hours)

  ;; the default working week (any job without authored rows): Mon-Sat 9-17
  (record [k job] 0 (weekly [monday tuesday wednesday thursday friday saturday] #9:00 #17:00))

  ;; priest: irregular week - Sunday IS the working day; omitted days are off
  (record [k priest] 0 (weekly [sunday] #8:00 #13:00))
  (record [k priest] 0 (weekly [wednesday] #10:00 #12:00))
  (record [k priest] 0 (weekly [saturday] #16:00 #18:00))

  ;; nurse: the hospital runs round the clock - a day shift and a night shift
  (record [k nurse] 0 (weekly [sunday monday tuesday wednesday thursday friday saturday] #7:00 #19:00))
  (record [k nurse] 1 (weekly [sunday monday tuesday wednesday thursday friday saturday] #19:00 #7:00))

  ;; factory-worker: day AND night shifts; a hand is assigned one at hire
  (record [k factory-worker] 0 (weekly [monday tuesday wednesday thursday friday saturday] #6:00 #18:00))
  (record [k factory-worker] 1 (weekly [monday tuesday wednesday thursday friday saturday] #18:00 #6:00)))
