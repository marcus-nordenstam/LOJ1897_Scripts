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
; LANE: a yearly timer ((schedule cooldown 1 y)) fires the failure roll once a year and
; mints the LATCHED winding-up goal. The derived means / merit dims are (target ...)
; reads, cached annually by derive_prototypes - the same reads the founding events use.
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
  (if (= (economic-climate) panic)     (then 4.0)
    (else (if (= (economic-climate) downturn)  (then 2.0)
      (else (if (= (economic-climate) expansion) (then 0.5)
        (else 1.0)))))))                              ; stable

; --- the decision -------------------------------------------------------------
(npc-think close_business
  ; ANNUAL: a yearly timer runs the failure roll once per year. No cadence marker - the
  ; (schedule ...) is the cadence.
  (schedule cooldown 1 y)
  (if-blocked hold)
  (rng-stream business)

  ; Light @self gate; the owner + business-kind identification is the cached
  ; ?org role; the articles filter caches as EXISTENCE and binds ?art at fire.
  (role @self (grown @self))
  (role ?org (believes {@self employer [k org business]:?org})
             (believes {?org founder @self})
             (believes {?org record ?art}))

  ; The once-a-year failure roll (base x climate x means-penalty x merit-penalty;
  ; wealth / diligence are his OWN derived dims, read as the founding events do), an
  ; ONSET: (eval-until-hold) rolls it at the fire and LOCKS it once the goal holds (it
  ; re-rolls each year until it lands). MAINTENANCE - the decision OWNS the winding-up
  ; goal focused on his OWN articles end to end. The ?org role's {@self employer [k org
  ; business]:?org} filter is the CONTINUOUS completion gate: while he is still the seated
  ; proprietor the goal stands; once close_business_act shutters the premises and
  ; reconcile_closed (perceiving the closed doors) ends his {@self employer ?org}, the
  ; role drops and the cease-effects retract the goal.
  (when (eval-until-hold
          (chance (* (* (business_failure_base) (business_failure_climate_mult))
                     (* (+ 1.0 (* (business_failure_means_weight) (- 1.0 (target {@self wealth}))))
                        (+ 1.0 (* (business_failure_merit_weight)  (- 1.0 (diligence)))))))))
  (effects       (begin-goal {@self close_business ?art}))
  (cease-effects (end-goal   {@self close_business ?art})))

; TERMINAL (act_body_purification): AT his own premises, PROPOSE the winding-up. close_business is
; a proposed label, so the bare {@self close_business} goal no longer promotes on its own - the act
; runs ONLY here, ONLY once the owner has reached the premises (at-workplace). articles-building
; binds ?wp (the firm's premises) off the goal-focus - the same read the close_go routing rung uses
; (npc-think/close_business_errand.hs), whose (not (at-workplace ?wp)) gate this arrived condition
; negates. The (goal ...) gate supplies the /cause. Reactive (schedule always): re-proposes each
; decision point while the winding-up goal stands + he is at the premises.
(npc-think close_at_premises
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self close_business})
  (when (and (articles-building (goal-focus close_business) ?wp)
             (at-workplace ?wp)))
  (utility 85)
  (effects (maintain-proposal {@self close_business})))
