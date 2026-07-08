; ----------------------------------------------------------------------------
; Employment life-cycle (Phase 7): hiring, the boss's staff review (which both
; promotes and dismisses), retirement.
; All operate through the hsim_org_lifecycle verbs; "employed" is the presence
; of an ongoing {@self employer ?} belief, "rank" is the level belief on the
; worker's job object (read via job-level).
;
; EMERGENT (Section 4.11): no (schedule) - all fire via the per-NPC emergent
; pass (institutional acts gated on the actor's own beliefs + the org articles,
; no physical co-presence), MONTHLY. hiring is an eligibility MATCH (match-job
; binds the job kind, hire-seq mints the beliefs); retirement keeps its /12
; age-gated chance. PERFORMANCE outcomes
; (phase 3) - promotion AND dismissal - are decided in ONE boss-side pass
; (job_loss -> review-own-staff): the employer reads HIS OWN work_standing
; assessment of each worker (phase 2) and rises the excellent / lets go those
; below the keep-threshold (mass economic layoffs remain business_failure's job).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; --- hiring: a jobless working-age adult is taken on by some org -------------
(hsim-npc-behaviour hiring
  (long-term-think)
  (rng-stream employment)

  ;; The jobless adult (@self) is the deliberator: he looks for work this month.
  ;; The org is the inner role. age / situation / chance are non-belief ops, so
  ;; they gate the fire in (when), not role selection.
  (roles
    (role @self (template any_human)
                (not (believes {@self employer ?})))
    ;; A known org (@self learned it at new_job_orientation - a mental org object
    ;; carrying its isa belief), excluding households: an org but NOT a labour-market
    ;; employer - its servants are taken on by the staff_household pass (role-
    ;; appropriate, gender-normed), never as generic clerks here. Belief-pure +
    ;; cached: the old (kind ...) / org-kind-is-a omniscient doc ops are gone.
    (role ?org (template known_org)
               (not (believes {?this isa [k org household]}))))

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
  ; {@self goal {@self engage_staff ?articles}}; the npc-act (hire_errand.hs)
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
    (begin-goal {@self engage_staff (target {?org record})})))

; --- staff review: a boss reviews their own staff and promotes / dismisses -----
; BOSS-DRIVEN THINK (perf inversion). Both performance outcomes are the EMPLOYER's
; decision, made from the employer's OWN assessment of their OWN staff - so @self is
; the BOSS, not the workforce. A window-start think gated to the employed;
; review-own-staff then confirms @self heads their org and walks only that
; establishment's register, reading its OWN work_standing beliefs (no worker-mind
; read) and, per worker, minting in ONE pass either {@self goal {@self sack <w>}}
; for an underperformer (standing below the 0.4 keep-threshold, likelier the lower)
; or {@self goal {@self promote_staff <w>}} for an excellent one (above the 0.7
; promote floor). The two bands cannot overlap, and work_standing is a slow monthly
; accumulator starting at the neutral 0.5, so a promotion is implicitly tenure-gated
; (the old explicit job-tenure / job-skilled-at-or-above gates are subsumed).
; The intra-day acts execute the decision AT the workplace: sack_errand.hs fires the
; man (and seeds his grudge toward the boss); promote_errand.hs advances his grade
; (promote() caps the rise at senior - headship is succession-only). This replaces
; the old worker-first promotion enumeration (every human x an O(all-articles)
; boss_of scan to reach the boss-side assessment), which dominated the world lane.
(hsim-npc-behaviour job_loss
  (long-term-think)
  (rng-stream employment)

  (roles
    (role @self (template any_human)
                (believes {@self employer ?})))

  (effects
    ; The boss's own decision policy: below 0.4 standing risks the sack at
    ; 0.08/month per unit of gap; above 0.7 earns promotion consideration at
    ; 0.12/month per unit. The goals feed sack_errand / promote_errand.
    (review-own-staff @self sack 0.4 0.08 promote_staff 0.7 0.12)))

; --- retirement: an employed worker of 65+ leaves working life --------------
; SPLIT (Item 5, the great split): this event is now the npc-THINK - the decision
; to retire. It no longer ends the job here; it mints {?worker goal {?worker retire}}.
; The npc-ACT (events/work/retire.hs) routes the worker to their workplace and the
; completion fires the actual (fire) commit - so a retirement happens AT the
; workplace, by the man himself, generating the co-presence a witness would see.
(hsim-npc-behaviour retirement
  (long-term-think)
  (rng-stream employment)

  ;; The worker (@self) decides to retire; age + chance -> (when).
  (roles
    (role @self (template any_human)
                (believes {@self employer ?})))

  ; Re-firing is harmless: (goal) is idempotent, so re-rolling the chance while the
  ; worker still holds an unacted retire goal just re-mints the same goal (no-op).
  (when (and (>= (years-old @self) 65)
             (chance 0.033)))   ; /12 of the old annual 0.4 (now monthly)

  (effects
    (begin-goal {@self quit_work})
    ))
