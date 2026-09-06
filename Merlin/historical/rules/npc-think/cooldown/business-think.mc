; ----------------------------------------------------------------------------
; Business life-cycle (Phase 7). The merit-gated routes into proprietorship -
; investment, business_partnership, business_founding.
;
; A man's rise into ownership is not a class privilege: diligence, a sound
; character and means put a non-noble man within reach of a business. The
; three founding rules are the three routes to those means:
;   - investment          - a backer puts up the capital,
;   - business_partnership - an established proprietor takes him on as co-owner,
;   - business_founding   - he self-funds, or founds on a backer's capital.
; Each gates on merit (a high `diligence` dimension), character (a sound
; `respectability_situation`) and means (`wealth`, or a `backed-by` belief).
; The derived dimensions are read via (belief-target ...) - they are cached
; each December by derive_prototypes, so the January founding rules see the
; prior year's appraisal.
;
; CATALOG ORDER MATTERS. investment is authored FIRST so the `backed-by`
; beliefs it writes are visible to business_founding the same January tick.
; The three rules partition the merit candidates with no overlap: a wealthy
; or backed man founds; a poor-but-worthy man with a business-owner friend
; partners; investment claims poor-but-worthy men a year ahead of founding.
;
; LANE SPLIT: the founding routes (investment / business_partnership /
; business_founding / business_homeostat) are EMERGENT - fired MONTHLY for each
; NPC, so each (chance) is /12 to hold the annual rate. The first three are
; MERIT-gated; business_homeostat is the non-merit floor net (founds from any adult
; while the town is below its business floor). NB the catalog-order dependency
; (investment before founding, for backed-by) resolves within the one monthly
; round, which runs them in catalog order.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; --- investment: a worthy clerk secures his firm's backing -----------------
(npc-think investment
  (cooldown 1 m)
  (rng-stream business)

  ; SELF-POV (reframe 2026-06-23): the worthy CLERK is the deliberator and seeks his
  ; own FIRM's backing to set up on his own account. The worker-firm bond is
  ; the KNOWN connection (both already know each other), so there is no blind candidate
  ; scan and no telepathy. This replaces the old backer-scans-all-candidates form, which
  ; never connected - a backer almost never KNEW an eligible clerk, so the candidate's
  ; banded diligence/repute @failed: 628k futile candidate-evals / 0 backings, and a
  ; 450ms+ per-run perf hog. @self weighs his OWN merit + means here, exactly like
  ; business_partnership (which fires healthily). A backed clerk then founds his own
  ; business via business_founding's `backed-by` means-branch.
  ; A merit-and-character clerk who can weigh his own standing (the belief-pure
  ; part). The backing firm is his job's org, bound as ?org via the ?job role's
  ; {?job org ?org} (threaded off {@self job ?job}). The working-age band, not-
  ; already-an-owner, merit and means dims, the completion gate and the onset
  ; chance live in (when ...) below.
  (role @self (old_human @self)
              {@self wealth ?wealth}
              -{@self backed-by ?}
              -{@self job [k head-of-non-household-org]}
              (or {@self repute [k respectable]}
                  {@self repute [k exemplary]}))
  (role ?job {@self job ?job})
  (role ?org {?job org ?org})          ; produced-restricted: ?org threaded off ?job

  ; MAINTENANCE: the decision OWNS the back goal end to end. (not backed-by) is the
  ; CONTINUOUS completion gate - while he is still unbacked the goal stands; the moment
  ; invest_act seals it ({@self backed-by ?}) the gate falls and the goal ends. The
  ; (chance) is an ONSET roll - (latch-eval) rolls it at the fire and LOCKS it once
  ; holding (re-rolling each month until it lands). The working-age band, not-already-an-
  ; owner and the merit + means dims stay live gates.
  (when (and (>= (years-old @self) 25)
             (<= (years-old @self) 55)
             (>= (diligence) 0.55)
             (< ?wealth 0.5)
             (latch-eval (chance (* 0.033 (+ 0.5 (attr @self assertiveness)))))))

  ; npc-think: the clerk resolves to secure his firm's backing. Mints {@self goal
  ; {@self back ?org}} (focus = the firm); the npc-action (invest_errand.hs)
  ; sends him to the firm and the completion records {@self backed-by ?org} there -
  ; which trips the completion gate above. Focus = the firm ?org, bound in the role
  ; from @self's own job.org belief. cease-effects end the goal on that falling edge.
  (utility errand)
  (effects (maintain-proposal {@self back ?org})))

; --- business_partnership: an established proprietor takes on a co-owner ----
; SELF-POV (telepathy purge CAT-2): the clerk is the sole deliberator - he weighs
; his OWN standing (diligence / repute / wealth, all self-beliefs) and resolves to
; buy into a firm. @self, no counterpart mind is read.
(npc-think business_partnership
  (cooldown 1 m)
  (rng-stream business)

  ; A merit-and-character man who cannot self-fund and is not backed - the
  ; clerk-makes-partner route (the belief-pure part). The age band, not-already-an-
  ; owner, merit + means dims and the monthly chance are non-belief and live in
  ; (when ...) below.
  (role @self (old_human @self)
              {@self wealth ?wealth}
              (or {@self repute [k respectable]}
                  {@self repute [k exemplary]})
              -{@self backed-by ?}
              -{@self job [k head-of-non-household-org]})
  (role ?job {@self job ?job}
             {?job org ?})             ; threaded job.org existence
  ; An existing business he is taken into - a KNOWN org of business kind (@self
  ; learned it at new_job_orientation). Belief-pure + cached. (The plan links
  ; principal and candidate by a prior bond - friend / former master / club
  ; co-member; v1 gates on the candidate's merit alone, as the relationship layer
  ; is not yet rich enough to gate on without starving the rule.)
  (role ?principal_org (known_org ?principal_org)
                       [k org business])

  ;; Live exclusivity re-check (see betrothal.hs): the candidate's "not
  ;; org-head" eligibility is evaluated at enumeration time, so within one
  ;; january tick several businesses can each sample the same strong candidate
  ;; before any partnership commits - one man "taken into partnership" by a
  ;; dozen firms. The when_gate is evaluated live per firing; once the candidate
  ;; has been made an org-head this tick, the re-check fails and the sampler
  ;; backtracks to another candidate.
  ;; MAINTENANCE: that same "not org-head" test is ALSO the CONTINUOUS completion
  ;; gate - the hold re-checks the (when) each pass, so the moment partner_act seats
  ;; him as proprietor (org-head) it falls and the goal ceases. The (chance) is the
  ;; ONSET roll: (latch-eval) rolls it at the fire and LOCKS it once holding. The
  ;; working-age band and the merit + means dims stay live gates.
  (when (and (>= (years-old @self) 25)
             (<= (years-old @self) 55)
             (>= (diligence) 0.55)
             (< ?wealth 0.5)
             (latch-eval (chance (* 0.01 (+ 0.5 (attr @self assertiveness)))))))

  ; SPLIT (Item 5): the npc-think - the clerk decides to buy in. Mints {@self
  ; goal {@self PARTNER <articles>}}; the npc-action (partner_errand.hs) sends him to
  ; the firm's premises and the completion buys him in there. RE-TARGET pattern:
  ; a search-type pursuit holds ONE standing goal, replaced (not stacked) each
  ; fire - begin-goal is idempotent only per identical target and each firm's
  ; articles is a DISTINCT object, so an accumulating mint overflowed the
  ; attention set (13 standing goals by 1707); a blocking goal gate instead
  ; deadlocks the search on an unreachable first target. (end-goal) no-ops when
  ; no goal stands. Focus = the firm's articles ({?org record ?art}).
  (utility errand)
  (effects
    (end-goal {@self PARTNER})
    (begin-goal {@self PARTNER (any {?principal_org record}).target}))
  (cease-effects (end-goal {@self PARTNER})))

; --- business_founding: a man of means sets up on his own account ----------
; SPLIT (Item 5, the great split): this is now the npc-THINK - the decision to
; set up in business. It mints {?founder goal {?founder FOUND}}; the npc-action
; (rules/work/found_business.hs) routes the founder to the bank and the
; completion does the real (found-org) commit - so the business is founded at the
; bank, by the man himself, leaving the founding documents (the clue trail) and the
; co-presence a witness would see, instead of a faceless world-lane edit.
(npc-think business_founding
  (cooldown 1 m)
  (rng-stream business)

  ; Merit, character, and means - either enough wealth to self-fund, or a
  ; backer (the backed-by belief a prior patronage / investment errand wrote).
  ; SELF-POV (telepathy purge CAT-2): @self weighs his OWN standing; no other
  ; mind is read. Belief-pure part only; the age band, not-already-an-owner, merit
  ; dim, means branch and the monthly chance are non-belief and live in (when ...).
  (role @self (old_human @self)
              {@self wealth ?wealth}
              -{@self job [k head-of-non-household-org]}
              (or {@self repute [k respectable]}
                  {@self repute [k exemplary]}))
  (role ?job {@self job ?job}
             {?job org ?})             ; threaded job.org existence

  ; MAINTENANCE: the decision OWNS the found goal end to end. (not org-head) is the
  ; CONTINUOUS completion gate - while he is not yet a proprietor the goal stands; the
  ; hold re-checks the (when) each pass, so the moment found_business_act seats him as
  ; org-head it falls and the goal ceases. The (chance) is an ONSET roll - (eval-until-
  ; hold) rolls it at the fire and LOCKS it once holding. The working-age band, merit
  ; dim and the means branch (enough wealth OR a backer) stay live gates.
  (when (and (>= (years-old @self) 25)
             (<= (years-old @self) 55)
             (>= (diligence) 0.55)
             (or (>= ?wealth 0.5)
                 {@self backed-by ?})
             (latch-eval (chance (* 0.025 (+ 0.5 (attr @self assertiveness)))))))

  (utility errand)
  (effects       (begin-goal {@self FOUND}))
  (cease-effects (end-goal   {@self FOUND})))

; --- business_homeostat: the org-supply floor, founder-by-founder --------------
; The safety net that sustains EMPLOYMENT across generations. The MERIT founding
; rules above require the founder to ALREADY be employed + monied, so once the
; seed businesses die out the eligible pool empties and founding stops (observed:
; founding ends ~cycle 42, employment by ~cycle 208). This rule founds from ANY
; alive adult of founding age - breaking that chicken-and-egg - but ONLY while the
; town sits below its business floor (one per dozen souls). It mints the SAME
; {@self goal {@self FOUND}} the merit path does, so the found_business errand
; (roll a housable kind -> leave the old post -> found-org-seq) does the founding,
; at a bank, with the clue trail - no faceless world edit, no C++ hire().
;
; EMERGENT per-NPC: fired MONTHLY. The
; (orgs-below-population-floor ...) gate is LIVE, so it stops minting once
; the town is at floor; a small (chance) throttles the per-month volume so the
; goal->commit lag cannot overshoot far. Premises availability self-limits it too.
(npc-think business_homeostat
  (cooldown 1 m)
  (rng-stream business)
  ; Serialize the floor-net decision: one founder reads the org registry, mints
  ; the FOUND goal and (on founding) appends the kind before the next reads it -
  ; so parallel deliberation cannot overshoot the floor off one stale count.
  (lock-rule)

  ; Any alive adult - the belief-pure part is just the template. NO merit gate
  ; (that is the whole point of the floor net). The founding-age band, not-already-
  ; an-owner, not-already-pursuing, the LIVE business-floor gate and the chance are
  ; all non-belief and live in (when ...) below.
  (role @self (old_human @self)
              -{@self job [k head-of-non-household-org]})

  ; MAINTENANCE floor-net (co-minter of {@self FOUND} alongside business_founding). The
  ; CONTINUOUS completion gate is org-head (falls when he founds -> cease). The ONSET group
  ; (latch-eval) is rolled at the fire and locked once holding: the monthly chance, the
  ; not-already-pursuing self-dedup (would self-defeat if re-checked - it minted the goal), and
  ; the LIVE business-floor gate (do not abort a founding-in-flight if the floor recovers).
  (when (and (>= (years-old @self) 25)
             (<= (years-old @self) 55)
             (latch-eval (chance 0.05)
                              -{@self goal {@self FOUND}}
                              (< (* (count-orgs-isa [k org business]) 12)
                                 (living-npc-count)))))

  (utility errand)
  (effects       (begin-goal {@self FOUND}))
  (cease-effects (end-goal   {@self FOUND})))
