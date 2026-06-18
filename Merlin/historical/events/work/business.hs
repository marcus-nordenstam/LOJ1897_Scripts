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

  (roles
    ; A merit-and-character man of working age who cannot self-fund and is
    ; not already backed.
    ; Dimensions are float 0..1 post-normalisation (the old 0..100 thresholds
    ; could never pass - investment/partnership/founding silently never fired;
    ; the homeostat masked it).
    (role ?candidate (template old_human)
                     (>= (years-old ?this) 25)
                     (<= (years-old ?this) 55)
                     (believes ?this {@self employer ?})
                     (not (= (job-level ?this) [k org_head]))
                     (>= (belief-target ?this diligence) 0.55)
                     (or (= (belief-target ?this repute) [k respectable])
                         (= (belief-target ?this repute) [k exemplary]))
                     (< (belief-target ?this wealth) 0.5)
                     (not (believes ?this {@self backed_by ?}))
                     ; /12 of the old annual 0.40 (now monthly).
                     (chance (* 0.033 (+ 0.5 (attr ?this assertiveness)))))
    ; A man of means - comfortable or better - who backs the venture. (The
    ; plan draws the backer from the candidate's social circle; v1 gates on
    ; means alone - the typed-relationship layer the circle needs is not yet
    ; rich enough to gate on without starving the event.)
    (role ?investor (template old_human)
                    (not (= ?this ?candidate))
                    (or (= (belief-target ?this economic_situation) [k comfortable])
                        (= (belief-target ?this economic_situation) [k prosperous])
                        (= (belief-target ?this economic_situation) [k wealthy]))))

  ; SPLIT (Item 5): the npc-think - the BACKER decides to back the candidate. Mints
  ; {?investor goal {?investor back ?candidate}}; the npc-act (invest_errand.hs)
  ; sends the investor to call on the candidate and the completion records the
  ; {candidate backed_by investor} there. (goal) is idempotent.
  (effects
    (goal ?investor back ?candidate)))

; --- business_partnership: an established proprietor takes on a co-owner ----
(hsim-event business_partnership
  (nl         "?candidate is taken into partnership")
  (rng-stream business)

  (roles
    ; A merit-and-character man who cannot self-fund and is not backed - the
    ; clerk-makes-partner route.
    ; Float 0..1 thresholds - see the investment role's note.
    (role ?candidate (template old_human)
                     (>= (years-old ?this) 25)
                     (<= (years-old ?this) 55)
                     (believes ?this {@self employer ?})
                     (not (= (job-level ?this) [k org_head]))
                     (>= (belief-target ?this diligence) 0.55)
                     (or (= (belief-target ?this repute) [k respectable])
                         (= (belief-target ?this repute) [k exemplary]))
                     (< (belief-target ?this wealth) 0.5)
                     (not (believes ?this {@self backed_by ?}))
                     ; /12 of the old annual 0.12 (now monthly).
                     (chance (* 0.01 (+ 0.5 (attr ?this assertiveness)))))
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
  (when (not (= (job-level ?candidate) [k org_head])))

  ; SPLIT (Item 5): the npc-think - the clerk decides to buy in. Mints {?candidate
  ; goal {?candidate partner ?principal_articles}}; the npc-act (partner_errand.hs)
  ; sends him to the firm's premises and the completion buys him in there. (goal)
  ; is idempotent.
  (effects
    (goal ?candidate partner ?principal_articles)))

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
    ; backer (the backed_by belief investment wrote earlier this tick).
    ; Float 0..1 thresholds - see the investment role's note.
    (role ?founder (template old_human)
                   (>= (years-old ?this) 25)
                   (<= (years-old ?this) 55)
                   (believes ?this {@self employer ?})
                   (not (= (job-level ?this) [k org_head]))
                   (>= (belief-target ?this diligence) 0.55)
                   (or (= (belief-target ?this repute) [k respectable])
                       (= (belief-target ?this repute) [k exemplary]))
                   (or (>= (belief-target ?this wealth) 0.5)
                       (believes ?this {@self backed_by ?}))
                   ; /12 of the old annual 0.30 (now monthly).
                   (chance (* 0.025 (+ 0.5 (attr ?this assertiveness))))))

  ; Re-firing is harmless: (goal) is idempotent, so re-rolling the chance while the
  ; founder still holds an unacted found goal just re-mints the same goal (no-op).
  (effects
    (goal ?founder found)))

; --- business_failure: an org folds (zero-role; see header) -----------------
(hsim-event business_failure
  (nl         "businesses fail in hard times")
  (schedule   (annually december))
  (rng-stream business)

  (effects
    (fail-businesses 0.02)))

; --- business_homeostat: org-supply floor (Phase 2) -------------------------
; A ZERO-ROLE homeostat (see business_failure's header for the zero-role
; rationale - found-businesses scans and CREATES entities, which must not run
; inside a role-enumeration mx_for_each_entity walk). Keeps the town's business
; count near one per dozen souls, founding new ones while below that floor.
;
; This is what sustains EMPLOYMENT across generations. The merit-gated founding
; events above require the founder to ALREADY be employed and monied, so once
; the seed businesses die out the eligible pool empties, founding stops, and
; employment bleeds to zero (observed: founding ends ~cycle 42, employment by
; ~cycle 208). found-businesses founds from any alive adult of founding age,
; breaking that chicken-and-egg; the existing `hiring` event then staffs the
; new businesses from the jobless.
(hsim-event business_homeostat
  (nl         "the town's commerce keeps pace with its people")
  (schedule   (annually january))
  (rng-stream business)

  (effects
    (found-businesses 12)))
