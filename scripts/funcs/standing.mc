; ----------------------------------------------------------------------------
; standing - how @self comes to regard the people he knows by who they ARE, judged once a night.
;
; Everyone he has ever held a bond to at acquaintance or closer is judged on what he knows of
; them: their conduct against his own standard, their class against his, a fortune above his
; own (envy), and the company they keep (the friends of those he dislikes).
; Between adults his orientation admits and who are not his kin, their mate value - looks and
; standing, weighed by his sex, less the years between them - draws him (attraction, and the
; longing that is its felt surface). Each pull is gentle; a difference that lasts accumulates.
; ----------------------------------------------------------------------------

; How much each kind of conduct weighs on esteem, warmth and trust; a vice counts inverted.
(define-table conduct_stance (fields dim esteem warmth trust vice)
  (record honesty     0.25 0.10 0.40 0)
  (record piety       0.30 0.15 0.05 0)
  (record sobriety    0.20 0.10 0.10 0)
  (record decorum     0.25 0.20 0.05 0)
  (record criminality 0.40 0.30 0.50 1))

; What draws a man or a woman in another: looks and standing.
(define-table mate_value_weights (fields gender looks status)
  (record [k male]   0.70 0.20)
  (record [k female] 0.35 0.55))

; Which sex an orientation is drawn to.
(define-table orientation_draw (fields orient same-sex opposite-sex)
  (record [k hetero] 0 1)
  (record [k homo]   1 0)
  (record [k bi]     1 1))

(define-macro standing-lr () 0.0375)
(define-macro attraction-lr () 0.10)
(define-macro caring-base () 0.4)
(define-macro class-match-warmth () 0.08)
(define-macro class-mismatch-warmth () 0.20)
(define-macro envy-esteem () 0.30)
(define-macro envy-gap-min () 0.15)
(define-macro transitive-warmth () 0.25)
(define-macro adult-age () 16.0)
(define-macro age-gap-penalty () 0.50)
(define-macro standing-envy-hours () 96.0)
(define-macro longing-hours () 96.0)

; A conduct level as virtue: a vice's level inverted.
(define-func virtue-of (?level ?vice)
  (if (= ?vice 1) (then (- 1.0 ?level)) (else ?level)))

; ?who's ?label level when known, else -1.0.
(define-func known-level (?who ?label)
  (target-or ?who ?label -1.0))

; ?who's age in years when his birth date is known, else -1.0.
(define-func known-age (?who)
  (if (any {?who birth-date ?}): ?born (then (floor (age ?born.target))) (else -1.0)))

; The mean upward gap between ?other's prestige and wealth and @self's, over the ones known of both.
(define-func fortune-gap (?other)
  (bind (known-level ?other prestige) ?their-prestige)
  (bind (known-level @self prestige) ?my-prestige)
  (bind (known-level ?other wealth) ?their-wealth)
  (bind (known-level @self wealth) ?my-wealth)
  (bind (if (and (>= ?their-prestige 0.0) (>= ?my-prestige 0.0)) (then 1.0) (else 0.0)) ?np)
  (bind (if (and (>= ?their-wealth 0.0) (>= ?my-wealth 0.0)) (then 1.0) (else 0.0)) ?nw)
  (if (> (+ ?np ?nw) 0.0)
      (then (/ (+ (* ?np (- ?their-prestige ?my-prestige)) (* ?nw (- ?their-wealth ?my-wealth)))
               (+ ?np ?nw)))
      (else 0.0)))

; Envy of ?other's fortune, over what @self knows of it.
(define-func feel-envy (?other ?gap)
  (if (any {?other prestige ?}): ?fortune
      (then (mint-emotion-caused [k envy] ?other (* (standing-envy-hours) ?gap) ?fortune))
      (else (if (any {?other wealth ?}): ?riches
                (then (mint-emotion-caused [k envy] ?other (* (standing-envy-hours) ?gap) ?riches))))))

(define-func judge-standing-of (?other)
  (bind 0.0 ?dw)
  (bind 0.0 ?de)
  (bind 0.0 ?dt)
  (for-each-row conduct_stance [/dim ?dim] [/esteem ?we] [/warmth ?ww] [/trust ?wt] [/vice ?vice]
    (bind (known-level ?other ?dim) ?theirs)
    (if (>= ?theirs 0.0)
        (then
          (bind (known-level @self ?dim) ?mine)
          (bind (+ (caring-base) (if (>= ?mine 0.0) (then (virtue-of ?mine ?vice)) (else 0.5))) ?caring)
          (bind (* ?caring (* (- (virtue-of ?theirs ?vice) 0.5) 2.0)) ?pull)
          (bind (+ ?de (* ?we ?pull)) ?de)
          (bind (+ ?dw (* ?ww ?pull)) ?dw)
          (bind (+ ?dt (* ?wt ?pull)) ?dt))))
  (bind (target-or @self class-situation @nothing) ?my-class)
  (bind (target-or ?other class-situation @nothing) ?their-class)
  (if (and (substantial ?my-class) (substantial ?their-class))
      (then (if (= ?my-class ?their-class)
                (then (bind (+ ?dw (class-match-warmth)) ?dw))
                (else (bind (- ?dw (class-mismatch-warmth)) ?dw)))))
  (bind (fortune-gap ?other) ?gap)
  (if (> ?gap (envy-gap-min))
      (then
        (bind (- ?de (* (envy-esteem) ?gap)) ?de)
        (feel-envy ?other ?gap)))
  (bind (+ ?dw (* (transitive-warmth)
                  (sum-over ?tie {?other friend ?f} (min (stance ?f warmth) 0.0)))) ?dw)
  (nudge-stance ?other warmth (* ?dw (standing-lr)))
  (nudge-stance ?other esteem (* ?de (standing-lr)))
  (nudge-stance ?other trust (* ?dt (standing-lr))))

; Does @self's orientation draw him to ?other's sex? An unknown orientation reads as the common one.
(define-func drawn-to (?same-sex)
  (bind (target-or @self sexual-orient @nothing) ?orient)
  (bind (if (substantial ?orient) (then ?orient) (else [k hetero])) ?orient)
  (if (table-match orientation_draw orient ?orient same-sex ?same opposite-sex ?opposite)
      (then (= (if ?same-sex (then ?same) (else ?opposite)) 1))
      (else @false)))

(define-func judge-attraction-of (?other)
  (bind (target-or @self gender @nothing) ?my-sex)
  (bind (target-or ?other gender @nothing) ?their-sex)
  (bind (known-age @self) ?my-age)
  (bind (known-age ?other) ?their-age)
  (if (and (substantial ?my-sex) (substantial ?their-sex)
           (drawn-to (= ?my-sex ?their-sex))
           (not {@self (kin-labels) ?other})
           (or (< ?my-age 0.0) (>= ?my-age (adult-age)))
           (or (< ?their-age 0.0) (>= ?their-age (adult-age)))
           (table-match mate_value_weights gender ?my-sex looks ?w-looks status ?w-status))
      (then
        (bind (+ (* ?w-looks (max (known-level ?other attractiveness) 0.0))
                 (* ?w-status (max (known-level ?other prestige) 0.0))) ?value)
        (if (and (>= ?my-age 0.0) (>= ?their-age 0.0))
            (then (bind (- ?value (* (age-gap-penalty) (/ (difference ?my-age ?their-age) 10.0))) ?value)))
        (if (> ?value 0.0)
            (then
              (nudge-stance ?other attraction (* ?value (attraction-lr)))
              (if (any {?other attractiveness ?}): ?looks
                  (then (mint-emotion-caused [k longing] ?other (* (longing-hours) ?value) ?looks))
                  (else (if (any {?other prestige ?}): ?standing
                            (then (mint-emotion-caused [k longing] ?other (* (longing-hours) ?value)
                                                       ?standing))))))))))

(define-func /sleep judge-standing ()
  (for-each-distinct ?other {@self (closeness-labels acquaintance) ?other /ever}
    (judge-standing-of ?other)
    (judge-attraction-of ?other)))
