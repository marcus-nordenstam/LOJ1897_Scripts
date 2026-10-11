; ----------------------------------------------------------------------------
; read-job-board ?board - go to the parish church that keeps the job board and read every
; notice posted there that @self has not read (read-doc); reading a notice is how he learns
; of the vacancy it names. Preparation for getting a job (thinks/hot/job-search-think.mc).
; ----------------------------------------------------------------------------

(task {@self read-job-board ?board}:?read-job-board
  (aspect labour)
  (preparatory)
  (tar [k church-building] @object)
  (stable-or
    (try
      (lock)
      (role ?ad [k job-posting] (spatial ?ad building ?board)
                                -{@self READ ?ad /succ}
                                (select (score (near @self ?ad)) (policy first-match))
        (effects (maintain-proposal {@self read-doc ?ad}))))
    (try
      (when (not (spatial @self building ?board)))
      (effects (maintain-proposal {@self go-to ?board})))
    (try
      (no-role [k job-posting] (spatial ?norole building ?board) -{@self READ ?norole /succ})
      (effects (set-outcome ?read-job-board /succ)))))
