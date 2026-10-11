; ----------------------------------------------------------------------------
; Employment life-cycle (Phase 7): hiring, the boss's staff review (which both
; promotes and dismisses), retirement.
; All operate through the hsim_org_lifecycle verbs; "employed" is the presence
; of an ongoing {@self job ?} belief, "rank" is the level belief on the
; worker's job object.
;
; hiring is an eligibility MATCH (the (select-row ...) in hire_errand_act binds
; the job kind, hire-seq mints the beliefs); retirement is an age-gated chance.
; PERFORMANCE outcomes (phase 3) - promotion AND dismissal - are decided in ONE
; boss-side pass (job_loss -> review-own-staff): the boss reads HIS OWN
; work-standing assessment of each worker (phase 2) and rises the excellent / lets
; go those below the keep-threshold (mass economic layoffs remain business_failure's job).
; ----------------------------------------------------------------------------


; --- hiring: the labour market (advert -> application -> offer -> enrolment) --
; Lives in job_search_think.mc (worker side) + recruit_think.mc (recruiter side,
; driven by the recruit-staff duty) + recruit_actions.mc (the clerical writes).

; --- staff review: the boss reviews each worker he has assessed ------------------
; Whoever holds the org's dismiss_staff / review_staff duty reads his own {?w work-standing}
; of each worker: below 0.4 risks the sack (the dismiss task), above 0.7 earns a promotion.
; The roll is latched, so the task holds until it concludes.
(driver sack-review
  (cooldown 1 m try-once)
  (rng-stream employment)
  (role @self {@self duty-to ?org dismiss_staff}
    (role ?w    {?w work-standing ?ws}
      (when (and (!= ?w @self)
                 (> 0.4 ?ws)
                 (latch-eval (chance (* 0.08 (- 0.4 ?ws))))))
      (declare-utility errand)
      (effects (maintain-proposal {@self dismiss ?w})))))

(driver promote-review
  (cooldown 1 m try-once)
  (rng-stream employment)
  (role @self {@self duty-to ?org review_staff}
    (role ?w    {?w work-standing ?ws}
      (when (and (!= ?w @self)
                 (> ?ws 0.7)
                 (latch-eval (chance (* 0.12 (- ?ws 0.7))))))
      (declare-utility errand)
      (effects (maintain-proposal {@self promote-staff ?w})))))

; --- retirement: an employed worker of 65+ leaves working life, at his workplace (the retire
; task), so it happens where his colleagues see it. The roll is latched.
(driver retirement
  (cooldown 1 m try-once)
  (rng-stream employment)
  (role @self {@self age ?age}
              {@self job ?}
    (when (and (>= ?age 65)
               (latch-eval (chance 0.033))))
    (declare-utility errand)
    (effects (maintain-proposal {@self retire}))))
