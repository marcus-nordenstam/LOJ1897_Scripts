; ----------------------------------------------------------------------------
; want-work - a jobless man of working age who needs a wage (job-seeker, funcs/hiring.mc)
; intends to get a job, caused by the life-aim he holds. The intent stands until he is taken
; on: pursue-get-job (thinks/hot/job-search-think.mc) reads the board, applies and takes up
; an offer.
; ----------------------------------------------------------------------------

(intender want-work
  (aspect labour)
  (role @self {@self age ?age}
              {@self life-aim ?}:?aim
              -{@self job ?}
    (when (job-seeker @self ?age))
    (declare-utility errand)
    (effects (maintain-intent {@self intent {@self get-job}} /caused_by ?aim))))
