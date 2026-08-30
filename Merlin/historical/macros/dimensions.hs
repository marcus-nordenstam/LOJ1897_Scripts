; ----------------------------------------------------------------------------
; dimensions.hs - value-dimension DEFS (define-macro). A value dim is a 0..1
; magnitude a fusion or utility reads on demand - never a minted belief. Each is
; an ordinary zero-arg macro inlined by every consumer (written (dimname)), so
; there is ONE encoding and no classifier catalog to evaluate it.
;
; The macro bodies are ordinary .hs read/fold expressions (attr / believes /
; (count (every ..)) / evidence + the + - * / min max clamp >= <=
; combinators). (believes {@self L ?}) is the boolean "holds an ongoing L"
; (0-or-1 in arithmetic); (count (every {@self L ?})) the ongoing tally;
; (count (every {@self L ? /ever})) the any-tense tally (ended act-records count); the
; per-attr default is 0 when absent (traits are always present on generated
; humans).
; ----------------------------------------------------------------------------

; --- per-observer repute fold (uniform for @self and a tracked other) ------------
; repute reads BANDED conduct beliefs {X <dim> <conduct_level>} + {X devoutness},
; the {X decorum} float, and per-observer chastity - all keyed on ?who, so ONE fold
; serves self-repute (?who = @self) and other-repute (?who = a tracked person). An
; absent band reads `fair` (unknown -> benefit of the doubt, 0.65), so an unknown
; other reads RESPECTABLE and only accumulated negative evidence drags them down;
; reputation sharpens only with evidence.

; conduct-scalar - a conduct_level band -> 0..1 (good 0.85, lax 0.25, fair/absent 0.65).
(define-macro conduct-scalar (?who ?dim)
  (if {?who ?dim [k conduct_level good]} (then 0.85)
  (else (if {?who ?dim [k conduct_level lax]}  (then 0.25)
      (else 0.65)))))

; devoutness-scalar - the piety_band -> 0..1 (devout 0.85, secular 0.25, else 0.65).
(define-macro devoutness-scalar (?who)
  (if {?who devoutness [k piety_band devout]}  (then 0.85)
  (else (if {?who devoutness [k piety_band secular]} (then 0.25)
      (else 0.65)))))

; decorum-scalar - the decorum float (@self's own C++-derived value, or a tracked
; other's mirrored value), reading 0.65 when unknown.
(define-macro decorum-scalar (?who)
  (if {?who decorum ?} (then (any {?who decorum}).target) (else 0.65)))

; chastity-scalar - 0.85 minus a rung per extra-marital liaison THIS mind knows of
; ?who (uniform: @self's own affairs for @self, the observer's knowledge for others).
(define-macro chastity-scalar (?who)
  (- 0.85 (* (>= (count (every {?who lover ? /ever})) 1) 0.30)
          (* (>= (count (every {?who lover ? /ever})) 2) 0.30)))

; repute-fold - the seven-term mean the repute band-cut reads, for @self or ?other.
(define-macro repute-fold (?who)
  (/ (+ (conduct-scalar ?who honesty)
        (conduct-scalar ?who diligence)
        (conduct-scalar ?who generosity)
        (conduct-scalar ?who sobriety)
        (devoutness-scalar ?who)
        (decorum-scalar ?who)
        (chastity-scalar ?who)) 7))

; criminality - a low base (0.05), raised 0.25 per recorded crime of ANY tense. Violence
; (every (theme violent_to) act - the fight-lane blows, the organic-brawl PUNCH, and kill)
; is counted through the theme expansion, since there is no `assault` term any more; theft /
; fraud / embezzlement / kidnap are the remaining crime act-records. Habitual offenders saturate.
(define-macro criminality ()
  (clamp (+ 0.05
            (* (+ (count (every {@self (theme-labels violent_to) ? /ever})) (count (every {@self steal ? /ever}))
                  (count (every {@self defraud ? /ever})) (count (every {@self embezzle ? /ever}))
                  (count (every {@self kidnap ? /ever}))) 0.25)) 0 1))

; rootedness - how established the NPC is in the community. Local lineage
; (mother / father), a spouse, children (each +0.06, capped at 4 = +0.24), a
; steady occupation, owned property and club membership each add a partial
; score; the sum clamps to 1. ANY held post roots (a proprietor, priest or
; household head is more rooted, not less - the paid/unpaid split is the
; money-seeking gates' concern, never rootedness). A recently-arrived
; immigrant with just a job reads low (~0.20); a settled local family high.
(define-macro rootedness ()
  (clamp (+ (* 0.15 (prob {@self mother ?}))
            (* 0.15 (prob {@self father ?}))
            (* 0.20 (prob {@self spouse ?}))
            (* 0.06 (min (count (every {@self child ?})) 4))
            (* 0.20 (prob {@self job ?}))
            (* 0.15 (>= (count (every {@self owns_building ?})) 1))
            (* 0.10 (>= (count (every {@self member_of ?})) 1))) 0 1))

; diligence - the industriousness aspect.
(define-macro diligence () (attr @self industriousness))

; honesty - high politeness, low Machiavellianism (the dark-tetrad deceit trait).
(define-macro honesty ()
  (/ (+ (attr @self politeness) (- 1 (attr @self machiavellianism))) 2))

; generosity - the compassion prior, lifted 0.20 by any recorded act of charity (an
; ended {@self give <alms>} act-record still counts - a lifetime tally).
(define-macro generosity ()
  (clamp (+ (attr @self compassion) (* (>= (count (every {@self give ? /ever})) 1) 0.20)) 0 1))

; sobriety - inverse of accumulated intoxication (absent intoxication = 0 = fully
; sober), hard-capped at 0.15 once a standing craving for drink has formed, and
; docked 0.25 x the gambling-addiction severity.
(define-macro sobriety ()
  (clamp (+ (* (- 1 (prob {@self craving ?})) (- 1 (attr @self intoxication)))
            (* (prob {@self craving ?})       (min (- 1 (attr @self intoxication)) 0.15))
            (* (attr @self gambling_addiction) -0.25)) 0 1))

; belonging - how well warmth bonds + immediate kin meet the sociability need.
; Warmth = friends (close_to / friend) + kin (spouse x2, children capped 5, parents
; capped 2, siblings capped 4). Need = 1 + Extraversion x 5 (Extraversion = the mean
; of enthusiasm + assertiveness); belonging falls 0.18 per unit of unmet need.
(define-macro belonging ()
  (clamp (- 1 (* (max (- (+ 1 (* (* (+ (attr @self enthusiasm) (attr @self assertiveness)) 0.5) 5))
                         (+ (count (every {@self close_to ?})) (count (every {@self friend ?}))
                            (* 2 (prob {@self spouse ?}))
                            (min (count (every {@self child ?})) 5)
                            (min (+ (count (every {@self mother ?})) (count (every {@self father ?}))) 2)
                            (min (+ (count (every {@self sibling ?})) (count (every {@self half_sibling ?}))) 4)))
                     0) 0.18)) 0 1))

; piety - worship-episode observance mapped onto the historical piety anchors:
; 0.25 the never-worships floor, 0.85 the regular-churchgoer ceiling. observance
; is the recency-weighted mass of the subject's OWN worship memories (forgetting
; them honestly degrades it; the church-going pretender fools it by design).
(define-macro piety ()
  (clamp (+ 0.25 (* (evidence @self WORSHIP 6 6) 0.60)) 0 1))

; inhibition - the moral / conscientious brake on pressure-driven impulse. A
; weighted fold of politeness / industriousness / compassion / piety / decorum
; minus the disinhibition trait-fold (low industriousness + low politeness + high
; volatility, inlined - the top-level name is taken by score_macros' inverse-
; inhibition reading) / stress, with the above-population-mean dark-tetrad terms
; (the one-sided amplification convention) and the held-value / justification
; counts. decorum is a C++ float belief and stress a mood belief - both read
; absent-safe (0 when the subject holds none, e.g. children / fresh spawns).
(define-macro inhibition ()
  (clamp (+ (+ (* (attr @self politeness)      0.30)
               (* (attr @self industriousness) 0.30)
               (* (attr @self compassion)      0.15)
               (* (piety)                       0.20)
               (* (if {@self decorum ?} (then (any {@self decorum}).target) (else 0)) 0.10)
               (* (/ (+ (- 1 (attr @self industriousness)) (- 1 (attr @self politeness))
                        (attr @self volatility)) 3) -0.20)
               (* (if {@self stress ?}  (then (any {@self stress}).target)  (else 0)) -0.30))
            (+ (* (clamp (+ (attr @self narcissism)       -0.5) 0 1) -0.10)
               (* (clamp (+ (attr @self machiavellianism) -0.5) 0 1) -0.15)
               (* (clamp (+ (attr @self psychopathy)      -0.5) 0 1) -0.20)
               (* (clamp (+ (attr @self sadism)           -0.5) 0 1) -0.25)
               (* (count (every {@self value ?}))    0.05)
               (* (count (every {@self justify ?})) -0.08))) 0 1))

; --- standing dims: prestige + decorum ------------------------------------------
; Both were C++ folds in the derive cascade; they are authored here so every
; consumer inlines ONE encoding, and the classifier rules (classifiers/prestige.hs,
; classifiers/decorum.hs) mint them as the {@self <dim>} floats the situation and
; life_aim role-gates read.

; job-rank - the economic-rank band of ?who's best current job: 5 for headship of
; a non-household org (headship trumps any grade), else the level_rung of the job's
; `level` belief, else -1 for the jobless. Feeds the prestige_by_rank lookup.
(define-macro job-rank (?who)
  (if {?who job ?}
    (then
      (if (is-a (any {?who job ?}).target [k head_of_non_household_org])
        (then 5)
        (else (if (table-match level_rank level
                    (any {(any {?who job ?}).target level ?}).target rank ?lvl_rank)
                (then ?lvl_rank)
                (else 0)))))
    (else -1)))

; win-prestige - a small capped bonus per recorded sporting victory (the `win`
; achievement beliefs): 0.04 each, capped at 0.20.
(define-macro win-prestige (?who)
  (min (* (count (every {?who win ?})) 0.04) 0.20))

; expert-prestige - the public-recognition bump a renowned expert carries: 0.15 for
; an `expert` skilled_in band in a publicly-esteemed domain (performance art,
; academic field, martial), 0 otherwise. The competence band is the belief's 4th
; field, so the domain and the band are matched together in one clause.
(define-macro expert-prestige (?who)
  (* 0.15
     (min (+ (prob {?who skilled_in [k performance_art] [k competence_level expert]})
             (prob {?who skilled_in [k academic_field]  [k competence_level expert]})
             (prob {?who skilled_in [k martial]         [k competence_level expert]}))
          1)))

; prestige-fold - public standing: the rank curve plus the win and expert bonuses,
; clamped to the 0..1 dimension scale.
(define-macro prestige-fold (?who)
  (clamp (+ (if (table-match prestige_by_rank rank (job-rank ?who) prestige ?rank_prestige)
              (then ?rank_prestige)
              (else 0.15))
            (win-prestige ?who)
            (expert-prestige ?who))
         0 1))

; decorum-fold - manners and propriety: the politeness aspect carried onto the
; dimension scale (the parallel of diligence <- industriousness).
(define-macro decorum-fold (?who)
  (clamp (attr ?who politeness) 0 1))
