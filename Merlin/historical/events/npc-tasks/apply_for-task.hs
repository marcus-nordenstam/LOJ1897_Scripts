; ----------------------------------------------------------------------------
; apply_for ?jk ?art - the WORKER's single job application (one at a time), and its OUTCOME
; is the whole lifecycle: running = applied, succ = took the job, fail = rejected (the /fail
; conclusion is the re-application memory). Drivers seek_board_visit / seek_apply_pick (which
; begin this) stay in job_search_think.hs. The head binds ?jk (job kind) + ?art (org
; articles) and captures :?af for the verdict tries.
;
;   gohome / write : go home, write the application (prepare_application stamps the org's
;                    address); mail delivers it to the workplace inbox - no trip there.
;   send  : hand the finished paper to the mail lane (one posting at a time via the lock;
;           above read_mail so an unposted paper always outbids the daily verdict read).
;   await_verdict : once daily at home, read the home post to learn the verdict.
;   take_up  : an OFFER letter read -> take up the post (a sub-task carrying job + articles).
;   rejected : a REJECTION letter read -> conclude /fail.
;   succeeded : the take-up concluded /succ -> employed -> conclude /succ.
; ----------------------------------------------------------------------------

(npc-task {@self apply_for ?jk ?art}:?af
  (tar job)
  (aux articles_of_incorporation)
  (and
    (try
      (role ?home {@self home ?home})
      (when (and (none {@self PREPARE_APPLICATION ?art ?jk /succ})
                 (not (spatial @self building ?home))))
      (effects (maintain-proposal {@self enter ?home})))
    (try
      (role ?home {@self home ?home})
      (when (and (none {@self PREPARE_APPLICATION ?art ?jk /succ})
                 (spatial @self building ?home)))
      (effects (maintain-proposal {@self PREPARE_APPLICATION ?art ?jk})))
    (try
      (lock-rule)
      (role ?app [k application] (select (policy first-match)))
      (when (and (read-doc-record [k application] ?app (find applicant @self))
                 (none {@self POST_MAIL ?app ? /succ})))
      (utility errand (above read_mail))
      (effects (debug-print "JS_SEND")
               (begin-proposal {@self send_mail ?app})))
    (try
      (role ?home {@self home ?home})
      (when (and (any {@self PREPARE_APPLICATION ?art ?jk /succ} (out int))
                 (spatial @self building ?home)
                 (>= (days-since-last {@self read_mail ?home /succ}) 1)))
      (utility errand)
      (effects (debug-print "JS_AWAIT")
               (maintain-proposal {@self read_mail ?home})))
    (try
      (role ?ltr [k offer_letter] {@self READ ?ltr /ever})
      (effects (debug-print "JS_TAKEUP")
               (maintain-proposal {@self take_up_post ?jk ?art})))
    (try
      (role ?ltr [k rejection_letter] {@self READ ?ltr /ever})
      (effects (set-outcome ?af fail)))
    (try
      (role @self (believes {@self take_up_post ?jk ?art /succ}))
      (effects (set-outcome ?af succ)))))
