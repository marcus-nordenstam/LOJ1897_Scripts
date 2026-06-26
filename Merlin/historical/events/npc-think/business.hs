; ----------------------------------------------------------------------------
; Business life-cycle (Phase 7). The merit-gated routes into proprietorship -
; investment, business_partnership, business_founding - plus business_failure.
;
; A man's rise into ownership is not a class privilege: diligence, a sound
; character and means put a non-noble man within reach of a business. The
; three founding events are the three routes to those means:
;   - investment          - a backer puts up the capital,
;   - business_partnership - an established proprietor takes him on as co-owner,
;   - business_founding   - he self-funds, or founds on a backer's capital.
; Each gates on merit (a high `diligence` dimension), character (a sound
; `respectability_situation`) and means (`wealth`, or a `backed_by` belief).
; The derived dimensions are read via (belief-target ...) - they are cached
; each December by derive_prototypes, so the January founding events see the
; prior year's appraisal.
;
; CATALOG ORDER MATTERS. investment is authored FIRST so the `backed_by`
; beliefs it writes are visible to business_founding the same January tick.
; The three events partition the merit candidates with no overlap: a wealthy
; or backed man founds; a poor-but-worthy man with a business-owner friend
; partners; investment claims poor-but-worthy men a year ahead of founding.
;
; business_failure is a ZERO-ROLE event: it has no per-entity role, so the
; engine fires it once each December with no role-enumeration walk in
; progress. The (fail-businesses ...) verb collects every org and dissolves
; the failures - dissolve_org destroys entities, which would corrupt an
; in-flight role-enumeration mx_for_each_entity.
;
; LANE SPLIT (Section 4.11): the NPC-caused founding routes (investment /
; business_partnership / business_founding / business_homeostat) are EMERGENT -
; no (schedule), fired by the per-NPC pass MONTHLY, so each (chance) is /12 to hold
; the annual rate. The first three are MERIT-gated; business_homeostat is the
; non-merit floor net (founds from any adult while the town is below its business
; floor). business_failure remains a TOWN-LEVEL zero-role market macro (world-act/
; business_macro.hs) and KEEPS its (schedule). NB the catalog-order dependency
; (investment before founding, for backed_by) resolves within the one monthly
; per-NPC pass, which runs them in catalog order.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; --- investment: a worthy clerk secures his employer's backing -------------
(hsim-event investment
  (sim-window-start)
  (nl         "@self resolves to seek backing to set up in business")
  (rng-stream business)

  ; SELF-POV (reframe 2026-06-23): the worthy CLERK is the deliberator and seeks his
  ; own EMPLOYER's backing to set up on his own account. The employer-employee bond is
  ; the KNOWN connection (both already know each other), so there is no blind candidate
  ; scan and no telepathy. This replaces the old backer-scans-all-candidates form, which
  ; never connected - a backer almost never KNEW an eligible clerk, so the candidate's
  ; banded diligence/repute @failed: 628k futile candidate-evals / 0 backings, and a
  ; 450ms+ per-run perf hog. @self weighs his OWN merit + means here, exactly like
  ; business_partnership (which fires healthily). A backed clerk then founds his own
  ; business via business_founding's `backed_by` means-branch.
  (roles
    ; A merit-and-character clerk of working age who cannot self-fund and is not yet
    ; backed. The backing firm is his employer, resolved in the effect via
    ; (target {@self employer}). Float 0..1 dim thresholds - see the partnership note.
    (role @self (template old_human)
                (>= (years-old @self) 25)
                (<= (years-old @self) 55)
                (believes {@self employer ?})
                (not (= (job-level @self) [k org_head]))
                (>= (target {@self diligence}) 0.55)
                (or (believes {@self repute [k respectable]})
                    (believes {@self repute [k exemplary]}))
                (< (target {@self wealth}) 0.5)
                (not (believes {@self backed_by ?}))
                ; /12 of the old annual 0.40 (now monthly).
                (chance (* 0.033 (+ 0.5 (attr @self assertiveness))))))

  ; npc-think: the clerk resolves to secure his employer's backing. Mints {@self goal
  ; {@self back ?org}} (focus = the employer firm); the npc-act (invest_errand.hs)
  ; sends him to the firm and the completion records {@self backed_by ?org} there.
  ; (goal) is idempotent. (`back` label reused as the clerk's pursue-backing goal.)
  ; Focus = the employer firm, read inline from @self's own employer belief.
  (effects
    (goal @self back (target {@self employer}))))

; --- business_partnership: an established proprietor takes on a co-owner ----
; SELF-POV (telepathy purge CAT-2): the clerk is the sole deliberator - he weighs
; his OWN standing (diligence / repute / wealth, all self-beliefs) and resolves to
; buy into a firm. @self, no counterpart mind is read.
(hsim-event business_partnership
  (sim-window-start)
  (nl         "@self is taken into partnership")
  (rng-stream business)

  (roles
    ; A merit-and-character man who cannot self-fund and is not backed - the
    ; clerk-makes-partner route.
    ; Float 0..1 thresholds - see the investment role's note.
    (role @self (template old_human)
                (>= (years-old @self) 25)
                (<= (years-old @self) 55)
                (believes {@self employer ?})
                (not (= (job-level @self) [k org_head]))
                (>= (target {@self diligence}) 0.55)
                (or (believes {@self repute [k respectable]})
                    (believes {@self repute [k exemplary]}))
                (< (target {@self wealth}) 0.5)
                (not (believes {@self backed_by ?}))
                ; /12 of the old annual 0.12 (now monthly).
                (chance (* 0.01 (+ 0.5 (attr @self assertiveness)))))
    ; An existing business he is taken into. (The plan links principal and
    ; candidate by a prior bond - friend / former employer / club co-member;
    ; v1 gates on the candidate's merit alone, as the relationship layer is
    ; not yet rich enough to gate on without starving the event.)
    (role ?principal_articles (template org_articles)
                              (org-kind-is-a ?this [k org business])))

  ;; Live exclusivity re-check (see betrothal.hs): the candidate's "not
  ;; org_head" eligibility is evaluated at enumeration time, so within one
  ;; january tick several businesses can each sample the same strong candidate
  ;; before any partnership commits - one man "taken into partnership" by a
  ;; dozen firms. The when_gate is evaluated live per firing; once the candidate
  ;; has been made an org_head this tick, the re-check fails and the sampler
  ;; backtracks to another candidate.
  (when (not (= (job-level @self) [k org_head])))

  ; SPLIT (Item 5): the npc-think - the clerk decides to buy in. Mints {@self
  ; goal {@self partner ?principal_articles}}; the npc-act (partner_errand.hs)
  ; sends him to the firm's premises and the completion buys him in there. (goal)
  ; is idempotent.
  (effects
    (goal @self partner ?principal_articles)))

; --- business_founding: a man of means sets up on his own account ----------
; SPLIT (Item 5, the great split): this is now the npc-THINK - the decision to
; set up in business. It mints {?founder goal {?founder found}}; the npc-act
; (events/work/found_business.hs) routes the founder to the bank and the
; completion does the real (found-org) commit - so the business is founded at the
; bank, by the man himself, leaving the founding documents (the clue trail) and the
; co-presence a witness would see, instead of a faceless world-lane edit.
(hsim-event business_founding
  (sim-window-start)
  (nl         "?founder resolves to set up in business")
  (rng-stream business)

  (roles
    ; Merit, character, and means - either enough wealth to self-fund, or a
    ; backer (the backed_by belief a prior patronage / investment errand wrote).
    ; SELF-POV (telepathy purge CAT-2): @self weighs his OWN standing; no other
    ; mind is read. Float 0..1 thresholds - see the investment role's note.
    (role @self (template old_human)
                (>= (years-old @self) 25)
                (<= (years-old @self) 55)
                (believes {@self employer ?})
                (not (= (job-level @self) [k org_head]))
                (>= (target {@self diligence}) 0.55)
                (or (believes {@self repute [k respectable]})
                    (believes {@self repute [k exemplary]}))
                (or (>= (target {@self wealth}) 0.5)
                    (believes {@self backed_by ?}))
                ; /12 of the old annual 0.30 (now monthly).
                (chance (* 0.025 (+ 0.5 (attr @self assertiveness))))))

  ; Re-firing is harmless: (goal) is idempotent, so re-rolling the chance while the
  ; founder still holds an unacted found goal just re-mints the same goal (no-op).
  (effects
    (goal @self found)))

; --- business_homeostat: the org-supply floor, founder-by-founder --------------
; The safety net that sustains EMPLOYMENT across generations. The MERIT founding
; events above require the founder to ALREADY be employed + monied, so once the
; seed businesses die out the eligible pool empties and founding stops (observed:
; founding ends ~cycle 42, employment by ~cycle 208). This event founds from ANY
; alive adult of founding age - breaking that chicken-and-egg - but ONLY while the
; town sits below its business floor (one per dozen souls). It mints the SAME
; {@self goal {@self found}} the merit path does, so the found_business errand
; (roll a housable kind -> leave the old post -> found-org-seq) does the founding,
; at a bank, with the clue trail - no faceless world edit, no C++ hire().
;
; EMERGENT per-NPC (was a zero-role world-act macro): fired MONTHLY by the per-NPC
; pass. The (orgs-below-population-floor ...) gate is LIVE, so it stops minting once
; the town is at floor; a small (chance) throttles the per-month volume so the
; goal->commit lag cannot overshoot far. Premises availability self-limits it too.
(hsim-event business_homeostat
  (sim-window-start)
  (nl         "@self resolves to set up in trade")
  (rng-stream business)

  (roles
    ; Any alive adult of founding age who is not already an owner and not already
    ; pursuing a founding - NO merit gate (that is the whole point of the floor net).
    (role @self (template old_human)
                (>= (years-old @self) 25)
                (<= (years-old @self) 55)
                (not (= (job-level @self) [k org_head]))
                (not (has-goal found))
                (orgs-below-population-floor [k org business] 12)
                ; a modest monthly chance: enough eligible adults resolve to found
                ; to refill the floor as businesses fail, without a goal-storm (the
                ; goal->bank->commit lag is premises-capped regardless).
                (chance 0.05)))

  (effects
    (goal @self found)))

; --- business_failure: an org folds (zero-role; see header) -----------------
