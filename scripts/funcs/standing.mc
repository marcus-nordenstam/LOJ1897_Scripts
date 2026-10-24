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

; How much each banded kind of conduct weighs on esteem, warmth and trust.
(define-table conduct_stance (fields dim esteem warmth trust)
  (record honesty  0.25 0.10 0.40)
  (record piety    0.30 0.15 0.05)
  (record sobriety 0.20 0.10 0.10))

; What draws a man or a woman in another: looks and standing.
(define-table mate_value_weights (fields gender looks status)
  (record [k male]   0.70 0.20)
  (record [k female] 0.35 0.55))

; Which sex an orientation is drawn to.
(define-table orientation_draw (fields orient same-sex opposite-sex)
  (record [k hetero] 0 1)
  (record [k homo]   1 0)
  (record [k bi]     1 1))


; ?who's age in years when his birth date is known, else -1.0.
(define-func known-age (?who)
  (flip (any {?who birth-date ?}): ?born (floor (age ?born.target)) -1.0))

; The mean upward gap between ?other's prestige and wealth and @self's, over the ones known of both.
(define-func fortune-gap (?other)
  (any {?other prestige ?their-prestige=-1.0})
  (any {@self prestige ?my-prestige=-1.0})
  (any {?other wealth ?their-wealth=-1.0})
  (any {@self wealth ?my-wealth=-1.0})
  (bind (flip (and (>= ?their-prestige 0.0) (>= ?my-prestige 0.0)) 1.0 0.0) ?np)
  (bind (flip (and (>= ?their-wealth 0.0) (>= ?my-wealth 0.0)) 1.0 0.0) ?nw)
  (flip (> (+ ?np ?nw) 0.0)
        (/ (+ (* ?np (- ?their-prestige ?my-prestige)) (* ?nw (- ?their-wealth ?my-wealth)))
           (+ ?np ?nw))
        0.0))

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
  (for-each-row conduct_stance [/dim ?dim] [/esteem ?we] [/warmth ?ww] [/trust ?wt]
    (band-virtue ?other ?dim @nothing): ?theirs
    (if (substantial ?theirs)
        (then
          (bind (+ (caring-base) (band-virtue @self ?dim 0.5)) ?caring)
          (bind (* ?caring (* (- ?theirs 0.5) 2.0)) ?pull)
          (bind (+ ?de (* ?we ?pull)) ?de)
          (bind (+ ?dw (* ?ww ?pull)) ?dw)
          (bind (+ ?dt (* ?wt ?pull)) ?dt))))
  (any {@self class-situation ?my-class=@nothing})
  (any {?other class-situation ?their-class=@nothing})
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
  (any {@self sexual-orient ?orient=@nothing})
  (bind (flip (substantial ?orient) ?orient [k hetero]) ?orient)
  (flip (table-match orientation_draw orient ?orient same-sex ?same opposite-sex ?opposite)
        (= (flip ?same-sex ?same ?opposite) 1)
        @false))

(define-func judge-attraction-of (?other)
  (any {@self gender ?my-sex=@nothing})
  (any {?other gender ?their-sex=@nothing})
  (any {@self age ?age=-1})
  (bind (+ /float ?age 0) ?my-age)
  (bind (known-age ?other) ?their-age)
  (if (and (substantial ?my-sex) (substantial ?their-sex)
           (drawn-to (= ?my-sex ?their-sex))
           -{@self (kin-labels) ?other}
           (or (< ?my-age 0.0) (>= ?my-age (adult-age)))
           (or (< ?their-age 0.0) (>= ?their-age (adult-age)))
           (table-match mate_value_weights gender ?my-sex looks ?w-looks status ?w-status))
      (then
        (any {?other attractiveness ?their-looks=-1.0})
        (any {?other prestige ?their-prestige=-1.0})
        (bind (+ (* ?w-looks (max ?their-looks 0.0))
                 (* ?w-status (max ?their-prestige 0.0))) ?value)
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
