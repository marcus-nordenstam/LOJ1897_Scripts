; ----------------------------------------------------------------------------
; close_business - the per-owner business-FAILURE decision.
;
; The flat annual 2% market cull becomes per-proprietor pressure: each December a
; business owner weighs his OWN standing (means + merit) against the town's
; economic weather and may resolve to wind the firm up. A struggling man (low
; wealth, slack diligence) in a downturn or panic folds far more readily than a
; wealthy, diligent one in an expansion - so failures cluster on the weak in bad
; years, instead of striking uniformly at random.
;
; ACTOR = the proprietor, identified from his OWN beliefs, NO world scan. ?org is
; a produced-restricted role threaded off ?job ({@self job ?job}):
;   {?job org [k org business]:?org} - he is seated at ?org AND ?org is-a
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
; The articles read (any {?org record ?art}) stays in (when ...) - a
; role filter cannot bind, and the suffix bind provably threads to the lifecycle
; block (same eval env; the retire / sack routing thinks rely on it).
;
; LANE: a yearly timer ((cooldown 1 y)) runs the failure roll once a year and
; mints the LATCHED winding-up goal. The derived means / merit dims are (target ...)
; reads, cached annually by derive_prototypes - the same reads the founding rules use.
;
; The routing (go / dwell) and the winding-up ACT live in the mirror errand file
; npc-act/close_business_errand.hs.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; --- failure-pressure tunables (rule-local content; see report note (b)) ------
; A shared tunables.hs home may be warranted if other lanes come to read the same
; base rate - flagged for reconciliation. Held here so the formula is one place.
(define-macro business_failure_base         () 0.02)   ; annual base failure rate (was fail-businesses 0.02)
(define-macro business_failure_means_weight () 1.5)    ; a penniless owner folds up to (1 + this)x more
(define-macro business_failure_merit_weight () 1.0)    ; a slack owner folds up to (1 + this)x more

; The ambient economic climate for the current sim year, as the historical era
; bands (pre-industrial agrarian, early industrial growth, the Hungry Forties, the
; mid-Victorian boom, the Long Depression). Atom-valued (stable | expansion |
; downturn), so compared, not scaled.
(define-macro economic-climate ()
  (if (< (year) 1820) (then stable)
    (else (if (< (year) 1846) (then expansion)
      (else (if (< (year) 1852) (then downturn)
        (else (if (< (year) 1874) (then expansion)
          (else (if (< (year) 1897) (then downturn)
            (else stable)))))))))))

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
  ; ANNUAL: a yearly timer runs the failure roll once per year.
  (cooldown 1 y)
  (rng-stream business)

  ; Light @self gate; the owner + business-kind identification is the cached
  ; ?org role; the articles filter caches as EXISTENCE and binds ?art at fire.
  (role @self (grown @self))
  (role ?job {@self job ?job})
  (role ?org {?job org [k org business]:?org}    ; produced-restricted: ?org threaded off ?job
             {@self wealth ?wealth}
             {?org founder @self}
             {?org record ?art})

  ; The once-a-year failure roll (base x climate x means-penalty x merit-penalty;
  ; wealth / diligence are his OWN derived dims, read as the founding rules do), an
  ; ONSET: (latch-eval) rolls it at the fire and LOCKS it once the goal holds (it
  ; re-rolls each year until it lands). MAINTENANCE - the decision OWNS the winding-up
  ; goal focused on his OWN articles end to end. The ?org role's {?job org [k org
  ; business]:?org} filter is the CONTINUOUS completion gate: while he is still the seated
  ; proprietor the goal stands; once close_business_act shutters the premises and
  ; reconcile_closed (perceiving the closed doors) ends his {@self job ?job}, the
  ; ?job role drops (and ?org with it) and the cease-effects retract the goal.
  (when (latch-eval
          (chance (* (* (business_failure_base) (business_failure_climate_mult))
                     (* (+ 1.0 (* (business_failure_means_weight) (- 1.0 ?wealth)))
                        (+ 1.0 (* (business_failure_merit_weight)  (- 1.0 (diligence)))))))))
  (utility errand)
  (effects       (begin-goal {@self CLOSE-BUSINESS ?art}))
  (cease-effects (end-goal   {@self CLOSE-BUSINESS ?art})))
