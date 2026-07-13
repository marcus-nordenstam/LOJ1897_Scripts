; ----------------------------------------------------------------------------
; close_business - the per-owner business-FAILURE decision (was the town-level
; zero-role (fail-businesses 0.02) world-act macro).
;
; The flat annual 2% market cull becomes per-proprietor pressure: each December a
; business owner weighs his OWN standing (means + merit) against the town's
; economic weather and may resolve to wind the firm up. A struggling man (low
; wealth, slack diligence) in a downturn or panic folds far more readily than a
; wealthy, diligent one in an expansion - so failures cluster on the weak in bad
; years, instead of striking uniformly at random.
;
; ACTOR = the proprietor, identified from his OWN beliefs, NO world scan. ?org is
; a CACHED role (both filters test the SAME candidate):
;   {@self employer [k org business]:?org} - he is seated at ?org AND ?org is-a
;                            trading firm, so churches / clubs / hospitals (public
;                            orgs, never "fail" this way) are excluded. The
;                            kind-cast matches the org OBJECT's permanent kind -
;                            never the decaying {?org isa ...} belief, which
;                            lapses at ~9 months and would darken the gate for
;                            any firm older than that. AND
;   {?org founder @self}   - the OWNER test. `founder`'s target is the REAL founder,
;                            so this holds ONLY for him. (record alone is NOT
;                            owner-exclusive: orient_errand mints {?org record ?art}
;                            for ANY worker who reads the articles at church - so a
;                            mere employee would falsely pass a record-only gate.)
; The articles bind {?org record ?art} stays in (when ...) - a role filter cannot
; bind, and the (bind {...}) provably threads to the lifecycle block (same eval
; env; the retire / sack routing thinks rely on the identical threading).
;
; LANE: (year-think december) - runs IN the intra-day cascade but is month-gated
; to December, so it is a fresh not-firing -> firing transition once a year and
; (first-fire-effects ...) mints the LATCHED goal exactly once. The derived means /
; merit dims are (target ...) reads, cached each December by derive_prototypes -
; the same reads the January founding events use.
;
; The routing (go / dwell) and the winding-up ACT live in the mirror errand file
; npc-act/close_business_errand.hs.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; --- failure-pressure tunables (event-local content; see report note (b)) ------
; A shared tunables.hs home may be warranted if other lanes come to read the same
; base rate - flagged for reconciliation. Held here so the formula is one place.
(define-macro business_failure_base         () 0.02)   ; annual base failure rate (was fail-businesses 0.02)
(define-macro business_failure_means_weight () 1.5)    ; a penniless owner folds up to (1 + this)x more
(define-macro business_failure_merit_weight () 1.0)    ; a slack owner folds up to (1 + this)x more

; The economic weather multiplier on the base rate: a panic wrecks businesses,
; an expansion sustains them. (economic-climate) is an ambient scalar read
; (decision #1 - allowed in a think). Atom-valued, so compared, not scaled.
(define-macro business_failure_climate_mult ()
  (if (= (economic-climate) panic)     4.0
    (if (= (economic-climate) downturn)  2.0
      (if (= (economic-climate) expansion) 0.5
        1.0))))                              ; stable

; --- the decision -------------------------------------------------------------
(npc-think close_business
  (year-think december)
  (rng-stream business)

  ; Light @self gate; the owner + business-kind identification is the cached
  ; ?org role; the articles filter caches as EXISTENCE and binds ?art at fire.
  (role @self (grown @self))
  (role ?org (believes {@self employer [k org business]:?org})
             (believes {?org founder @self})
             (believes {?org record ?art}))

  ; DETERMINISTIC (no chance): the gate must hold stably across every December
  ; intra-day cycle so the not-firing -> firing transition (hence first-fire)
  ; happens exactly ONCE. The stochastic failure roll lives in
  ; first-fire-effects, where it fires once per year - a chance IN the per-cycle
  ; gate would re-roll every cycle and inflate the annual rate toward certainty.

  ; The once-a-year failure roll (base x climate x means-penalty x merit-penalty;
  ; wealth / diligence are his OWN derived dims, read as the founding events do),
  ; guarding the LATCHED winding-up goal focused on his OWN articles (the errand
  ; routes to their premises and dissolves the firm there). first-fire runs once
  ; on the December transition, so the chance is rolled exactly once per year.
  (first-fire-effects
    (if (chance (* (* (business_failure_base) (business_failure_climate_mult))
                   (* (+ 1.0 (* (business_failure_means_weight) (- 1.0 (target {@self wealth}))))
                      (+ 1.0 (* (business_failure_merit_weight)  (- 1.0 (target {@self diligence})))))))
        (begin-goal {@self close_business ?art}))))
