; ----------------------------------------------------------------------------
; Dispositions (classifiers) - the higher-order traits, each minted as a {@self <dim> <float>}
; self-belief from the first-order traits and the derived states beneath it, so a rule reads
; the value off its own role like any other belief. Moods settle nightly, so the dims that
; fold a mood recompute daily; the rest fold slow inputs and recompute monthly.
; ----------------------------------------------------------------------------

; inhibition - the moral / conscientious brake on pressure-driven impulse. A weighted fold of
; politeness / industriousness / compassion / piety / decorum minus the disinhibition
; trait-fold (low industriousness + low politeness + high volatility) / stress, with the
; above-population-mean dark-tetrad terms (the one-sided amplification convention) and the
; held-value / justification counts. decorum and stress read 0 until they are derived.
(npc-think classify_inhibition
  (cooldown 1 d try-once)
  (role @self {@self politeness ?politeness}
              {@self industriousness ?industriousness}
              {@self compassion ?compassion}
              {@self volatility ?volatility}
              {@self narcissism ?narcissism}
              {@self machiavellianism ?machiavellianism}
              {@self psychopathy ?psychopathy}
              {@self sadism ?sadism}
    (effects
      (any {@self piety ?piety=0.25})
      (any {@self decorum ?decorum=0.0})
      (any {@self stress ?stress=0.0})
      (begin-belief {@self inhibition
                     (clamp (+ (+ (* ?politeness      0.30)
                                  (* ?industriousness 0.30)
                                  (* ?compassion      0.15)
                                  (* ?piety           0.20)
                                  (* ?decorum         0.10)
                                  (* (/ (+ (- 1.0 ?industriousness) (- 1.0 ?politeness) ?volatility) 3.0) -0.20)
                                  (* ?stress -0.30))
                               (+ (* (clamp (+ ?narcissism       -0.5) 0.0 1.0) -0.10)
                                  (* (clamp (+ ?machiavellianism -0.5) 0.0 1.0) -0.15)
                                  (* (clamp (+ ?psychopathy      -0.5) 0.0 1.0) -0.20)
                                  (* (clamp (+ ?sadism           -0.5) 0.0 1.0) -0.25)
                                  (* (count (every {@self value ?}) /float)    0.05)
                                  (* (count (every {@self justify ?}) /float) -0.08))) 0.0 1.0)}))))

; piety - worship-episode observance mapped onto the historical piety anchors: 0.25 the
; never-worships floor, 0.85 the regular-churchgoer ceiling. Observance is the
; recency-weighted mass of the subject's OWN worship memories.
(npc-think classify_piety
  (cooldown 1 m try-once)
  (role @self {@self age-band ?}
    (effects
      (begin-belief {@self piety (clamp (+ 0.25 (* (evidence @self WORSHIP 6 6) 0.60)) 0.0 1.0)}))))

; belonging - how well warmth bonds + immediate kin meet the sociability need. Warmth = friends
; (close-to / friend) + kin (spouse x2, children capped 5, parents capped 2, siblings capped 4).
; Need = 1 + Extraversion x 5 (Extraversion = the mean of enthusiasm + assertiveness);
; belonging falls 0.18 per unit of unmet need.
(npc-think classify_belonging
  (cooldown 1 m try-once)
  (role @self {@self enthusiasm ?enthusiasm}
              {@self assertiveness ?assertiveness}
    (effects
      (begin-belief {@self belonging
                     (clamp (- 1.0 (* (max (- (+ 1.0 (* (* (+ ?enthusiasm ?assertiveness) 0.5) 5.0))
                                              (+ (count (every {@self close-to ?}) /float)
                                                 (count (every {@self friend ?}) /float)
                                                 (* 2.0 (prob {@self spouse ?}))
                                                 (min (count (every {@self child ?}) /float) 5.0)
                                                 (min (+ (count (every {@self mother ?}) /float)
                                                         (count (every {@self father ?}) /float)) 2.0)
                                                 (min (+ (count (every {@self sibling ?}) /float)
                                                         (count (every {@self half-sibling ?}) /float)) 4.0)))
                                          0.0) 0.18)) 0.0 1.0)}))))

; rootedness - how established the NPC is in the community. Local lineage (mother / father),
; a spouse, children (each +0.06, capped at 4), a steady occupation, owned property and club
; membership each add a partial score; the sum clamps to 1. ANY held post roots. A
; recently-arrived immigrant with just a job reads low (~0.20); a settled local family high.
(npc-think classify_rootedness
  (cooldown 1 m try-once)
  (role @self {@self age-band ?}
    (effects
      (begin-belief {@self rootedness
                     (clamp (+ (* 0.15 (prob {@self mother ?}))
                               (* 0.15 (prob {@self father ?}))
                               (* 0.20 (prob {@self spouse ?}))
                               (* 0.06 (min (count (every {@self child ?}) /float) 4.0))
                               (* 0.20 (prob {@self job ?}))
                               (* 0.15 (>= (count (every {@self owns-building ?})) 1))
                               (* 0.10 (>= (count (every {@self member-of ?})) 1))) 0.0 1.0)}))))

; aggressive-tilt - the 1.0-centered multiplier an AGGRESSIVE outlet rides: dark tetrad +
; volatility amplify, politeness + compassion damp; the mood overlay rides a smaller swing on
; top. Each half clamps to [0, 2], so the product spans [0, 4].
(npc-think classify_aggressive_tilt
  (cooldown 1 d try-once)
  (role @self {@self narcissism ?narcissism}
              {@self machiavellianism ?machiavellianism}
              {@self psychopathy ?psychopathy}
              {@self sadism ?sadism}
              {@self volatility ?volatility}
              {@self politeness ?politeness}
              {@self compassion ?compassion}
    (effects
      (any {@self stress ?stress=0.5})
      (any {@self agitation ?agitation=0.5})
      (any {@self contentment ?contentment=0.5})
      (begin-belief {@self aggressive-tilt
                     (* (clamp (+ 1.0
                                  (- (+ (delib-ctr ?narcissism       (k-trait-swing))
                                        (delib-ctr ?machiavellianism (k-trait-swing))
                                        (delib-ctr ?psychopathy      (k-trait-swing))
                                        (delib-ctr ?sadism           (k-trait-swing))
                                        (delib-ctr ?volatility       (k-trait-swing)))
                                     (+ (delib-ctr ?politeness (k-trait-swing))
                                        (delib-ctr ?compassion (k-trait-swing))))) 0.0 2.0)
                        (clamp (+ 1.0
                                  (- (+ (delib-ctrc ?stress    (k-mood-swing))
                                        (delib-ctrc ?agitation (k-mood-swing)))
                                     (delib-ctrc ?contentment (k-mood-swing)))) 0.0 2.0))}))))

; prosocial-tilt - the PROSOCIAL twin: the same dimensions with the signs reversed, so the
; polite and compassionate confess and report where the dark and volatile expose and coerce.
(npc-think classify_prosocial_tilt
  (cooldown 1 d try-once)
  (role @self {@self politeness ?politeness}
              {@self compassion ?compassion}
              {@self volatility ?volatility}
              {@self narcissism ?narcissism}
              {@self machiavellianism ?machiavellianism}
              {@self psychopathy ?psychopathy}
              {@self sadism ?sadism}
    (effects
      (any {@self contentment ?contentment=0.5})
      (any {@self stress ?stress=0.5})
      (any {@self agitation ?agitation=0.5})
      (begin-belief {@self prosocial-tilt
                     (* (clamp (+ 1.0
                                  (- (+ (delib-ctr ?politeness (k-trait-swing))
                                        (delib-ctr ?compassion (k-trait-swing)))
                                     (+ (delib-ctr ?volatility       (k-trait-swing))
                                        (delib-ctr ?narcissism       (k-trait-swing))
                                        (delib-ctr ?machiavellianism (k-trait-swing))
                                        (delib-ctr ?psychopathy      (k-trait-swing))
                                        (delib-ctr ?sadism           (k-trait-swing))))) 0.0 2.0)
                        (clamp (+ 1.0
                                  (- (delib-ctrc ?contentment (k-mood-swing))
                                     (+ (delib-ctrc ?stress    (k-mood-swing))
                                        (delib-ctrc ?agitation (k-mood-swing))))) 0.0 2.0))}))))

; infidelity-disposition - the CHARACTER-cheater's straying tail: narcissistic supply-hunger
; + psychopathic thrill / low empathy + volatile impulsivity. A pure personality read - no
; family, marital or decorum term - so a serial cheater strays whatever their home life.
(npc-think classify_infidelity_disposition
  (cooldown 1 m try-once)
  (role @self {@self narcissism ?narcissism}
              {@self psychopathy ?psychopathy}
              {@self volatility ?volatility}
    (effects
      (begin-belief {@self infidelity-disposition
                     (* 0.3333 (+ ?narcissism ?psychopathy ?volatility))}))))
