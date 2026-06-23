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
; LANE SPLIT (Section 4.11): the three NPC-caused founding routes (investment /
; business_partnership / business_founding) are EMERGENT - no (schedule), fired
; by the per-NPC pass MONTHLY, so each (chance) is /12 to hold the annual rate.
; business_failure + business_homeostat are TOWN-LEVEL MACROS (zero-role market /
; homeostat regulators, NOT caused by a specific NPC) and KEEP their (schedule) -
; they stay on the DES (the scheduled-macro residents). NB the catalog-order
; dependency (investment before founding, for backed_by) now resolves within the
; one monthly per-NPC pass, which runs them in catalog order.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; --- investment: a backer puts up founding capital for a worthy man ---------
(hsim-event investment
  (nl         "?investor backs ?candidate's venture")
  (rng-stream business)

  ; SELF-POV (telepathy purge CAT-2): the BACKER is the sole deliberator. @self
  ; reads his OWN means, then judges a candidate he KNOWS from his OWN view of
  ; the man (3-arg (situation ?candidate <dim> @self) - diligence / repute / wealth
  ; banded in via believe_about). A candidate the backer has never met @fails the
  ; positive merit gates and is not backed - backing is grounded in acquaintance.
  (roles
    ; A man of means - comfortable or better - who decides to back a worthy man.
    (role @self (template old_human)
                (or (believes {@self economic_situation [k comfortable]})
                    (believes {@self economic_situation [k prosperous]})
                    (believes {@self economic_situation [k wealthy]})))
    ; A merit-and-character man of working age who cannot self-fund and is not
    ; already backed - judged from the backer's own knowledge of him.
    ; Dimensions are float 0..1 post-normalisation (the old 0..100 thresholds
    ; could never pass - investment/partnership/founding silently never fired;
    ; the homeostat masked it). NB the old (not org_head) rank gate is dropped:
    ; job-LEVEL is not a banded fact, so the backer cannot know it; "has a job +
    ; wealth < 0.5" already stands in for "a clerk, not a proprietor".
    (role ?candidate (template old_human)
                     (not (= ?candidate @self))
                     (>= (years-old ?candidate) 25)
                     (<= (years-old ?candidate) 55)
                     (believes {?candidate job ?})
                     (>= (target {?candidate diligence}) 0.55)
                     (or (believes {?candidate repute [k respectable]})
                         (believes {?candidate repute [k exemplary]}))
                     (< (target {?candidate wealth}) 0.5)
                     ; Not already backed - read from the BACKER's OWN knowledge
                     ; ({backed_by} is banded in via believe_about), no mind peek.
                     ; Permissive on the unknown: a same-tick double-back is left
                     ; to a future public-blackboard claim, not a telepathic read.
                     (not (believes {?candidate backed_by ?}))
                     ; /12 of the old annual 0.40 (now monthly).
                     (chance (* 0.033 (+ 0.5 (attr ?candidate assertiveness))))))

  ; SPLIT (Item 5): the npc-think - the BACKER decides to back the candidate. Mints
  ; {@self goal {@self back ?candidate}}; the npc-act (invest_errand.hs)
  ; sends the investor to call on the candidate and the completion records the
  ; {candidate backed_by investor} there. (goal) is idempotent.
  (effects
    (goal @self back ?candidate)))

; --- business_partnership: an established proprietor takes on a co-owner ----
; SELF-POV (telepathy purge CAT-2): the clerk is the sole deliberator - he weighs
; his OWN standing (diligence / repute / wealth, all self-beliefs) and resolves to
; buy into a firm. @self, no counterpart mind is read.
(hsim-event business_partnership
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

; --- business_failure: an org folds (zero-role; see header) -----------------
