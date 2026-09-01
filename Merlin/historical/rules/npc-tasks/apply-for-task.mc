; ----------------------------------------------------------------------------
; apply-for ?jk ?wp - the WORKER's single job application (one at a time), keyed on
; the job-kind + the WORKPLACE building the advert named. Its OUTCOME is the whole
; lifecycle: running = applied, succ = took the job, fail = rejected (the /fail
; conclusion is the re-application memory). Drivers seek_read_board / seek_apply_pick
; (which begin this) stay in job_search_think.hs.
;
;   gohome / write : go home, write + address the application (prepare-application);
;                    mail delivers it to the workplace inbox - no trip there.
;   send  : hand the finished paper to the mail lane.
;   await_verdict : once daily at home, read the home post to learn the verdict.
;   take_up  : an OFFER letter read -> take up the post (carrying job + workplace).
;   rejected : a REJECTION letter read -> conclude /fail.
;   succeeded : the take-up concluded /succ -> employed -> conclude /succ.
; ----------------------------------------------------------------------------

(npc-task {@self apply-for ?jk ?wp}:?af-rel
  (tar job)
  (aux building)
  (and
    (try
      (role ?home {@self home ?home})
      (when (and -{@self prepare-application ?wp ?jk /succ}
                 (not (spatial @self building ?home))))
      (effects (maintain-proposal {@self enter ?home})))
    (try
      (role ?home {@self home ?home})
      (when (and -{@self prepare-application ?wp ?jk /succ}
                 (spatial @self building ?home)))
      (effects (maintain-proposal {@self prepare-application ?wp ?jk})))
    (try
      (lock-rule)
      (role ?app [k application] (spatial ?app co-located @self)
            (select (policy first-match)))
      (when (and {@self prepare-application ?wp ?jk /succ}
                 -{@self STACK-PUT ?app ? /succ}))
      (utility errand (above read-mail))
      (effects (debug-print "JS_SEND")
               (begin-proposal {@self send-mail ?app})))
    (try
      (role ?home {@self home ?home})
      (when (and {@self prepare-application ?wp ?jk /succ}
                 (spatial @self building ?home)
                 (>= (days-since-last {@self read-mail ?home /succ}) 1)))
      (utility errand)
      (effects (debug-print "JS_AWAIT")
               (maintain-proposal {@self read-mail ?home})))
    (try
      (role ?ltr [k offer-letter] {@self READ ?ltr /ever})
      (effects (debug-print "JS_TAKEUP")
               (maintain-proposal {@self take-up-post ?jk ?wp})))
    (try
      (role ?ltr [k rejection-letter] {@self READ ?ltr /ever})
      (effects (set-outcome ?af-rel /fail)))
    (try
      (role @self {@self take-up-post ?jk ?wp /succ})
      (effects (set-outcome ?af-rel /succ)))))
