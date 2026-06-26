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
(hsim-event hiring
  (nl         "?worker is hired")
  (rng-stream employment)

  (roles
    ;; A jobless working-age adult looks for work this month. The (chance) is just
    ;; how often they SEEK - the real gate is the eligibility MATCH in the
    ;; `hire-matched` effect (Section 4.11 career model): per org, it reads the
    ;; org's needed job and the candidate's class / reputation / skills (+ the
    ;; tenure-conferred domain skill = experience), hiring into THAT job only if
    ;; eligible, weighted by a preferred-trait fit. So scandalous / under-skilled
    ;; / wrong-class applicants are filtered per JOB by the data, not here. The
    ;; scandalous gate stays as a coarse pre-filter (saves match work).
    (role ?worker (template any_human)
                  (>= (years-old ?this) 16)
                  (<= (years-old ?this) 55)
                  (not (believes ?this {@self employer ?}))
                  (not (= (situation ?this repute) [k scandalous]))
                  (chance 0.3))   ; how often a jobless adult seeks work (monthly)
    ;; A household is an org but NOT a labour-market employer: its servants
    ;; are taken on by the staff_household pass (role-appropriate,
    ;; gender-normed), never as generic clerks here.
    (role ?articles (template org_articles)
                    (not (org-kind-is-a ?this [k org household]))))

  ;; Live exclusivity re-check (see business.hs): the worker's "unemployed"
  ;; role filter is alpha-indexed, so within one tick every hiring org samples
  ;; the same available worker before the first hire commits - one man "hired"
  ;; by 20 firms. We re-check via (job-level ...) NOT (believes employer ...):
  ;; a computed op reads live, whereas a belief-pattern in the when_gate routes
  ;; through the same alpha-discriminator that's already stale. (hire ... :level
  ;; apprentice) sets the level live, so once hired this tick the worker reads
  ;; apprentice and the sampler backtracks to another candidate.
  (when (not (= (job-level ?worker) [k apprentice])))

  ; SPLIT (Item 5, EMPLOYEE-side job-search): the WORKER seeks work at the org. Mints
  ; {?worker goal {?worker engage_staff ?articles}}; the npc-act (hire_errand.hs)
  ; takes him to the firm and the eligibility-match hire commits there. Worker-driven
  ; (not the boss) so goals stay bounded - a boss-driven hire would pile EVERY jobless
  ; applicant's goal on one org-head and overflow the memory-fusion gather.
  (effects
    (goal ?worker engage_staff ?articles)))

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
(hsim-event job_loss
  (sim-window-start)
  (nl         "@self reviews their staff for promotions and dismissals")
  (rng-stream employment)

  (roles
    (role @self (template any_human)
                (believes {@self employer ?})))

  (effects
    (review-own-staff @self)))

; --- retirement: an employed worker of 65+ leaves working life --------------
; SPLIT (Item 5, the great split): this event is now the npc-THINK - the decision
; to retire. It no longer ends the job here; it mints {?worker goal {?worker retire}}.
; The npc-ACT (events/work/retire.hs) routes the worker to their workplace and the
; completion fires the actual (fire) commit - so a retirement happens AT the
; workplace, by the man himself, generating the co-presence a witness would see.
(hsim-event retirement
  (nl         "?worker decides to retire")
  (rng-stream employment)

  (roles
    (role ?worker (template any_human)
                  (believes ?this {@self employer ?})
                  (>= (years-old ?this) 65)
                  (chance 0.033)))   ; /12 of the old annual 0.4 (now monthly)
  ; Re-firing is harmless: (goal) is idempotent, so re-rolling the chance while the
  ; worker still holds an unacted retire goal just re-mints the same goal (no-op).

  (effects
    (goal ?worker quit_work)
    (log _retirement ?worker)))
