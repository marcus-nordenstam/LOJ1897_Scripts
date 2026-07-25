; ----------------------------------------------------------------------------
; Employment life-cycle (Phase 7): hiring, the boss's staff review (which both
; promotes and dismisses), retirement.
; All operate through the hsim_org_lifecycle verbs; "employed" is the presence
; of an ongoing {@self job ?} belief, "rank" is the level belief on the
; worker's job object (read via job-level).
;
; hiring is an eligibility MATCH (the (select-record ...) in hire_errand_act binds
; the job kind, hire-seq mints the beliefs); retirement is an age-gated chance.
; PERFORMANCE outcomes (phase 3) - promotion AND dismissal - are decided in ONE
; boss-side pass (job_loss -> review-own-staff): the boss reads HIS OWN
; work_standing assessment of each worker (phase 2) and rises the excellent / lets
; go those below the keep-threshold (mass economic layoffs remain business_failure's job).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- hiring: a jobless working-age adult is taken on by some org -------------
(npc-think hiring
  (cooldown 1 m)
  (rng-stream employment)

  ;; The jobless adult (@self) is the deliberator: he looks for work this month.
  ;; The org is the inner role. age / situation / chance are non-belief ops, so
  ;; they gate the fire in (when), not role selection.
  (role @self
              (not (believes {@self job.salary ?})))
  ;; A known org (@self learned it at new_job_orientation - a mental org object
  ;; carrying its isa belief), excluding households: an org but NOT a labour-market
  ;; firm - its servants are taken on by the staff_household pass (role-
  ;; appropriate, gender-normed), never as generic clerks here. Belief-pure +
  ;; cached: the old (kind ...) / org-kind-is-a omniscient doc ops are gone.
  (role ?org (known_org ?org)
             (not (believes {?org isa [k org household]}))
             (believes {?org record ?org_record}))

  ;; The (chance) is just how often @self SEEKS - the real gate is the eligibility
  ;; MATCH in the `engage_staff` act (Section 4.11 career model): per org, it reads
  ;; the org's needed job and the candidate's class / reputation / skills, hiring
  ;; into THAT job only if eligible. So scandalous / under-skilled / wrong-class
  ;; applicants are filtered per JOB by the data; the scandalous test here is a
  ;; coarse pre-filter. Live exclusivity re-check via (job-level ...) - a computed
  ;; op reads live, so once hired this tick @self reads apprentice and backtracks.
  (when (and (>= (years-old @self) 16)
             (<= (years-old @self) 55)
             (not (= (situation @self repute) [k scandalous]))
             (chance 0.3)
             (not (= (job-level @self) [k apprentice]))))

  ; SPLIT (Item 5, EMPLOYEE-side job-search): the WORKER seeks work at the org. Mints
  ; {@self goal {@self engage_staff ?articles}}; the npc-action (hire_errand.hs)
  ; takes him to the firm and the eligibility-match hire commits there. Worker-driven
  ; (not the boss) so goals stay bounded - a boss-driven hire would pile EVERY jobless
  ; applicant's goal on one org-head and overflow the memory-fusion gather.
  ; the org's articles (the goal focus the hire_errand reads) is recovered from
  ; @self's own {?org record ?art} belief, externalized to the env doc by (goal).
  ; RE-TARGET: one standing job-search goal, replaced each fire - at (chance 0.3)
  ; a chronically ineligible seeker otherwise stacks a distinct goal per firm's
  ; articles (30+ by 1706, the attention-set overflow), while a blocking has-goal
  ; gate would freeze the search on whichever firm was sampled first.
  (effects
    (end-goal {@self engage_staff})
    (begin-goal {@self engage_staff ?org_record}))
  ; The minter owns the ending: once @self is hired, the (role @self (not (believes
  ; {@self job.salary ?}))) falling edge ends the standing job-search goal. The act never does.
  (cease-effects (end-goal {@self engage_staff})))

; --- staff review: per-worker maintenance minters (dismiss / promote) ----------
; The boss OWNS each staffing intent end to end. @self is the BOSS: career conduct
; writes his own {?w work_standing <0..1>} assessment of each worker (boss-side via
; boss_of, no worker-mind read), so (role ?w (believes {?w work_standing ?ws}))
; enumerates exactly his assessed staff and fire-binds the score. A worker below the 0.4
; keep-line risks the sack; one above 0.7 earns a promotion; (latch-eval (chance ..))
; is the ONSET roll, locking once it lands. THE FALLING EDGE that ends the SPECIFIC goal is
; the worker leaving the role set: fire()/promote() clear the boss's {?w work_standing}
; assessment (hsim_org_lifecycle), so the acted-on worker drops out and (cease-effects
; (end-goal {@self sack|promote_staff ?w})) retires just his goal (target-specific). The
; intra-day sack/promote acts run pure effects - they never end the goal.
(npc-think sack_review
  (cooldown 1 m)
  (rng-stream employment)
  (role @self (believes {@self job [k org_head]}))  ; TODO(duty): gate on {@self duty_to ?org [k sack]}
  (role ?w    (believes {?w work_standing ?ws}))
  (when (and (not (= ?w @self))
             (> 0.4 ?ws)
             (latch-eval (chance (* 0.08 (- 0.4 ?ws))))))
  (effects       (begin-goal {@self sack ?w}))
  (cease-effects (end-goal   {@self sack ?w})))

(npc-think promote_review
  (cooldown 1 m)
  (rng-stream employment)
  (role @self (believes {@self job [k org_head]}))  ; TODO(duty): gate on {@self duty_to ?org [k promote]}
  (role ?w    (believes {?w work_standing ?ws}))
  (when (and (not (= ?w @self))
             (> ?ws 0.7)
             (latch-eval (chance (* 0.12 (- ?ws 0.7))))))
  (effects       (begin-goal {@self promote_staff ?w}))
  (cease-effects (end-goal   {@self promote_staff ?w})))

; --- retirement: an employed worker of 65+ leaves working life --------------
; SPLIT (Item 5, the great split): this event is now the npc-THINK - the decision
; to retire. It no longer ends the job here; it mints {?worker goal {?worker retire}}.
; The npc-ACT (events/work/retire.hs) routes the worker to their workplace and the
; completion fires the actual (fire) commit - so a retirement happens AT the
; workplace, by the man himself, generating the co-presence a witness would see.
(npc-think retirement
  (cooldown 1 m)
  (rng-stream employment)

  ;; The worker (@self) decides to retire; age + chance -> (when).
  (role @self
              (believes {@self job ?}))

  ; Re-firing is harmless: (goal) is idempotent, so re-rolling the chance while the
  ; worker still holds an unacted retire goal just re-mints the same goal (no-op).
  (when (and (>= (years-old @self) 65)
             (chance 0.033)))   ; /12 of the old annual 0.4 (now monthly)

  (effects
    (begin-goal {@self quit_work}))
  ; The minter owns the ending: once quit_work_act fires @self, the (role @self (believes
  ; {@self job ?})) drops and this falling edge ends the goal. The act never does.
  (cease-effects (end-goal {@self quit_work})))
