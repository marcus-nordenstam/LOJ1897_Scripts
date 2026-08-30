; ----------------------------------------------------------------------------
; take_up_post ?jk ?wp - the offered seeker goes to the workplace ?wp and takes the
; post (apply_for's success sub-task). Keyed on the job kind + the WORKPLACE building;
; the org's articles are the doc found AT the workplace (perceived on arrival). The
; chain concludes BOTTOM-UP: TAKE_POST stamps the world signal (job.salary), the
; outcome try's conclusive signal.
; ----------------------------------------------------------------------------

(npc-task {@self take_up_post ?jk ?wp}:?tup-rel
  (tar job)
  (aux building)
  (and
    (try
      (when (not (spatial @self building ?wp)))
      (effects (maintain-proposal {@self enter ?wp})))
    (try
      ; The wage book, perceived at the workplace; the task resolves it and hands it to
      ; the dumb ENROL - no org/register resolution inside the act.
      (role ?reg [k employee_register] (spatial ?reg building ?wp))
      (when (and (spatial @self building ?wp)
                 (>= (now-hour) 9)
                 (<= (now-hour) 16)
                 -{@self job.salary ?}))
      (effects (maintain-proposal {@self ENROL ?reg ?jk})))
    (try
      (role ?art [k articles_of_incorporation] (spatial ?art building ?wp))
      (role ?reg [k employee_register] (spatial ?reg building ?wp))
      (when (table-match (attr ?reg writing) worker @self level ?lvl))
      (effects (hire-beliefs ?art ?jk ?lvl)))
    (try
      (role @self {@self job.salary ?})
      (effects (debug-print "TUP_SUCC")
               (set-outcome ?tup-rel /succ)))))
