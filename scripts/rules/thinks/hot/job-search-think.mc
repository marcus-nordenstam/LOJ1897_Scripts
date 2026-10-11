; ----------------------------------------------------------------------------
; pursue-get-job - the WORKER side of the labour market (recruiter side: the recruit-staff
; task). An intent to get a job ({@self intent {@self get-job}}, minted by want-work,
; thinks/hot/want-work-think.mc) is pursued in business hours:
;   preparation - find the parish church when none is known; read its job board when no
;                 application is in flight; apply for a vacancy he knows of, qualifies for and
;                 has not applied for, one at a time (apply-for);
;   performance - an offer in hand ({?job offered-to @self}, read off the offer letter in the
;                 home post) is taken up at the org's door (accept-job-offer). Taken on, the
;                 intent ends; turned away, it stands and he applies elsewhere.
; ----------------------------------------------------------------------------

(include "../../../macros/tunables.mc")

(driver {@self intent {@self get-job}}:?intent
  (aspect labour)
  (rng-stream employment)
  (and
    (try
      (role ?job {?job offered-to @self}
        (when (and (hours (business_open_hour) (business_close_hour))
                   -{@self accept-job-offer ?job /succ}
                   -{@self accept-job-offer ?job /fail}))
        (effects (maintain-proposal {@self accept-job-offer ?job}))))

    ; ONE application at a time, and none while an offer waits to be taken up.
    (try
      (lock)
      (role @self -{? offered-to @self}
        (role ?org {?org workplace ?wp}
          (role ?job {?job org ?org}
                     {?job job-id ?}
                     -{? job ?job}
                     (select (score 1) (policy roulette))
            (when (and (hours (business_open_hour) (business_close_hour))
                       (kind ?job): ?jk
                       (if (table-match occupations job ?jk class-floor ?cf0) (then ?cf0) (else [k lower])): ?cf
                       (>= (cond
                             (case {@self class-situation [k upper]}  2)
                             (case {@self class-situation [k middle]} 1)
                             (case {@self class-situation [k lower]}  0)
                             (else -1)) (switch (kind ?cf)
                                          (on [k upper]  2)
                                          (on [k middle] 1)
                                          (else 0)))
                       -{@self apply-for ?job /succ}))
            (effects (maintain-proposal {@self apply-for ?job}))))))

    (try
      (role @self -{@self apply-for ? /pres}
        (role ?board [k church-building] (select (score (near @self ?board)) (policy roulette unknown-last))
          (when (and (hours (business_open_hour) (business_close_hour))
                     (>= (days-since-last {@self read-job-board ?board /succ}) (board_visit_days))))
          (effects (maintain-proposal {@self read-job-board ?board})))))

    (try
      (no-role [k church-building])
      (when (and (hours (business_open_hour) (business_close_hour))
                 -{@self find-building [k church-building] ? /fail}))
      (effects (maintain-proposal {@self find-building [k church-building] (current-exterior @self)})))))
