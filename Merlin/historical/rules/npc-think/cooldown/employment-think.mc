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

(include "../../../definitions/roles.mc")

; --- hiring: the labour market (advert -> application -> offer -> enrolment) --
; Lives in job_search_think.hs (worker side) + recruit_think.hs (recruiter side,
; driven by the recruit-staff duty) + recruit_actions.hs (the clerical writes).

; --- staff review: per-worker maintenance minters (dismiss / promote) ----------
; The boss OWNS each staffing intent end to end. @self is the BOSS: career conduct
; writes his own {?w work-standing <0..1>} assessment of each worker (boss-side via
; boss_of, no worker-mind read), so (role ?w (believes {?w work-standing ?ws}))
; enumerates exactly his assessed staff and fire-binds the score. A worker below the 0.4
; keep-line risks the sack; one above 0.7 earns a promotion; (latch-eval (chance ..))
; is the ONSET roll, locking once it lands. THE FALLING EDGE that ends the SPECIFIC goal is
; the worker leaving the role set: fire()/promote() clear the boss's {?w work-standing}
; assessment (hsim_org_lifecycle), so the acted-on worker drops out and (cease-effects
; (end-goal {@self SACK|promote-staff ?w})) retires just his goal (target-specific). The
; intra-day sack/promote acts run pure effects - they never end the goal.
(npc-think sack_review
  (cooldown 1 m)
  (rng-stream employment)
  ; Duty dispatch: whoever HOLDS the org's dismiss_staff duty reviews (assignment:
  ; duties_think.hs) - never a job-kind or rank test. Fire-binds ?org O(1).
  (role @self {@self duty-to ?org dismiss_staff})
  (role ?w    {?w work-standing ?ws})
  (when (and (!= ?w @self)
             (> 0.4 ?ws)
             (latch-eval (chance (* 0.08 (- 0.4 ?ws))))))
  (utility errand)
  (effects       (begin-goal {@self SACK ?w}))
  (cease-effects (end-goal   {@self SACK ?w})))

(npc-think promote_review
  (cooldown 1 m)
  (rng-stream employment)
  ; Duty dispatch: whoever HOLDS the org's review_staff duty promotes (assignment:
  ; duties_think.hs) - never a job-kind or rank test. Fire-binds ?org O(1).
  (role @self {@self duty-to ?org review_staff})
  (role ?w    {?w work-standing ?ws})
  (when (and (!= ?w @self)
             (> ?ws 0.7)
             (latch-eval (chance (* 0.12 (- ?ws 0.7))))))
  (utility errand)
  (effects (maintain-proposal {@self promote-staff ?w})))

; --- retirement: an employed worker of 65+ leaves working life --------------
; SPLIT (Item 5, the great split): this rule is now the npc-THINK - the decision
; to retire. It no longer ends the job here; it mints {?worker goal {?worker retire}}.
; The npc-ACT (rules/work/retire.hs) routes the worker to their workplace and the
; completion fires the actual (fire) commit - so a retirement happens AT the
; workplace, by the man himself, generating the co-presence a witness would see.
(npc-think retirement
  (cooldown 1 m)
  (rng-stream employment)

  ;; The worker (@self) decides to retire; age + chance -> (when).
  (role @self
              {@self job ?})

  ; Re-firing is harmless: (goal) is idempotent, so re-rolling the chance while the
  ; worker still holds an unacted retire goal just re-mints the same goal (no-op).
  (when (and (>= (years-old @self) 65)
             (chance 0.033)))   ; /12 of the old annual 0.4 (now monthly)

  (utility errand)
  (effects
    (begin-goal {@self QUIT-WORK}))
  ; The minter owns the ending: once quit_work_act fires @self, the (role @self (believes
  ; {@self job ?})) drops and this falling edge ends the goal. The act never does.
  (cease-effects (end-goal {@self QUIT-WORK})))
