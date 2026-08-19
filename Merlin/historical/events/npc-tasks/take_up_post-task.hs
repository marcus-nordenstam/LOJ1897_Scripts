; ----------------------------------------------------------------------------
; take_up_post - the offered seeker goes to the workplace and takes the post (apply_for's
; success sub-task, proposed by apply_for_take_up in job_search_think.hs). The head binds
; ?jk (job kind) + ?art (org articles) and captures :?tup-rel for the outcome try.
;
; and (not stable-or): the tries are a PROGRESSION gated by distinct phase conditions
; (outside->go, at-post-in-hours->take, enrolled->read book, salaried->conclude), never in
; competition, so an inclusive (and ...) reproduces the original independent rungs. The
; chain concludes BOTTOM-UP: TAKE_POST stamps the world signal (job.salary), which is the
; outcome try's conclusive signal.
; ----------------------------------------------------------------------------

(npc-task {@self take_up_post ?jk ?art}:?tup-rel
  (tar job)
  (aux articles_of_incorporation)
  (and
    (try
      (when (and (read-doc-record [k articles_of_incorporation] ?art (spatial ?wp building))
                 (not (spatial @self building ?wp))))
      (effects (maintain-proposal {@self enter ?wp})))
    (try
      (when (and (read-doc-record [k articles_of_incorporation] ?art (spatial ?wp building))
                 (spatial @self building ?wp)
                 (>= (now-hour) 9)
                 (<= (now-hour) 16)
                 (none {@self job.salary ?})))
      (effects (maintain-proposal {@self TAKE_POST ?art ?jk})))
    (try
      (role ?reg [k employee_register] (select (policy first-match)))
      (when (and (read-doc-record [k articles_of_incorporation] ?art (register ?reg))
                 (read-doc-record [k employee_register] ?reg (find worker @self) (level ?lvl))))
      (effects (hire-beliefs ?art ?jk ?lvl)))
    (try
      (role @self {@self job.salary ?})
      (effects (debug-print "TUP_SUCC art=?art")
               (set-outcome ?tup-rel succ)))))
