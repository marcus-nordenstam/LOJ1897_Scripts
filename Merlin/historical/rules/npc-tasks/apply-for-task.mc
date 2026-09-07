; ----------------------------------------------------------------------------
; apply-for ?jk ?wp - the WORKER's job application, keyed on the job-kind + the WORKPLACE
; building the advert named: go home, write + address the application
; (prepare-application), hand the paper to the mail lane, done - an hour's errand, not a
; lifecycle. Its /succ is the "applied" record the driver reads (seek_apply_pick applies
; once per post). The verdict arrives weeks later as a TYPED letter in the home post:
; reading an offer-letter drives take-up-post (job-search-think), a rejection-letter
; drives nothing. Drivers stay in job-search-think.
;
;   gohome / write : go home, write + address the application (prepare-application);
;                    mail delivers it to the workplace inbox - no trip there.
;   send  : hand the finished paper to the mail lane, from the HOME out-box (located first
;           if @self has never seen it).
;   posted : the mail lane took it -> conclude /succ.
; ----------------------------------------------------------------------------

(npc-task {@self apply-for ?jk ?wp}:?af-rel
  (tar job)
  (aux building)
  (and
    (try
      (role ?home {@self home ?home})
      (role @self (not (spatial @self building ?home)))
      (when -{@self prepare-application ?wp ?jk /succ})
      (effects (maintain-proposal {@self enter ?home})))
    (try
      (role ?home {@self home ?home})
      (role @self (spatial @self building ?home))
      (when -{@self prepare-application ?wp ?jk /succ})
      (effects (maintain-proposal {@self prepare-application ?wp ?jk})))
    (try
      (role ?home {@self home ?home})
      (no-role [k outgoing-mail-stack])
      (when {@self prepare-application ?wp ?jk /succ})
      (utility errand)
      (effects (maintain-proposal {@self locate [k outgoing-mail-stack] ?home})))
    (try
      (lock-rule)
      (role ?home {@self home ?home})
      (role ?out [k outgoing-mail-stack] (spatial ?out building ?home))
      (role ?app [k application] (spatial ?app co-located @self)
            (select (policy first-match)))
      (when (and {@self prepare-application ?wp ?jk /succ}
                 -{@self STACK-PUT ?app ? /succ}))
      (utility errand (above read-mail))
      (effects
               (maintain-proposal {@self send-mail ?app ?out})))
    (try
      (role @self {@self send-mail ? /succ /caused_by ?af-rel})
      (effects (set-outcome ?af-rel /succ)))))
