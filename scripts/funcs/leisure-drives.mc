; The leisure drives advance with the body at each charge, by the (construed-act ..) categories
; of the acts he is running then.

(include "../macros/leisure-macros.mc")
(include "../macros/tunables.mc")

(define-func leisure-mult (?swing-sum)
  (clamp (+ 1.0 ?swing-sum) (leisure-rate-mult-min) (leisure-rate-mult-max)))

(define-func sociability (?enthusiasm ?withdrawal)
  (clamp (- (+ 1.0 (delib-ctr ?enthusiasm (k-drive-trait-swing)))
            (delib-ctr ?withdrawal (k-drive-trait-swing)))
         0.0 (sociability-max)))

(define-func company-value (?enthusiasm ?withdrawal)
  (* (company-want-value)
     (flip {@self company [k isolated]} (isolated-company-level) (lonely-company-level))
     (sociability ?enthusiasm ?withdrawal)))

; His warmth toward the others in his conversation through its neutral point, (1 + warmth) / 2.
(define-func company-warmth ()
  (bind (conversation-of @self) ?talk)
  (bind 0.0 ?sum)
  (bind 0.0 ?count)
  (if (substantial ?talk)
      (then
        (for-each ?party (talk-participants ?talk)
          (if (neq ?party @self)
              (then (bind (+ ?sum (* 0.5 (+ 1.0 (stance ?party warmth)))) ?sum)
                    (bind (+ ?count 1.0) ?count))))))
  (cond (case (> ?count 0.0) (/ ?sum ?count))
        (else 0.5)))

; Above zero company relieves the hunger; below zero each social hour wears him toward crowded.
(define-func company-relief (?was ?hours ?warmth ?sociability)
  (bind (* (social-relief-per-hour) ?warmth) ?relief-rate)
  (bind (* (social-relief-per-hour) (- (sociability-max) ?sociability) (- 1.0 ?warmth)) ?wear-rate)
  (bind (* ?hours ?relief-rate) ?relief)
  (clamp (cond (case (<= ?was 0.0) (- ?was (* ?hours ?wear-rate)))
               (case (< ?relief ?was) (- ?was ?relief))
               (else (- 0.0 (* (- ?hours (/ ?was ?relief-rate)) ?wear-rate))))
         -1.0 1.0))

(define-func emit-leisure-bands (?strain ?tedium ?social-hunger)
  (mint-band {@self ease} ?strain [k frayed] (frayed-min) [k strained] (strained-min) [k at-ease] -1)
  (mint-band {@self stimulation} ?tedium [k restless] (restless-min) [k bored] (bored-min) [k engaged] -1)
  (mint-band {@self company} ?social-hunger [k isolated] (isolated-min) [k lonely] (lonely-min)
             [k companionable] (flip {@self company [k crowded]} (companionable-recovered-min) (companionable-min))
             [k crowded] -2))

; (social-span) - the span the body is charged for was spent in company: a social act ran through
; it, begun before this instant. An act born now did not, and one that ends now did.
(define-func social-span ()
  (bind @false ?social)
  (for-each ?act (every {@self (construed-labels social-act)})
    (if (> (elapsed /seconds ?act) 0)
        (then (bind @true ?social) (break))))
  ?social)

; (social-appetite) - how keen @self is on company now: his sociability, raised when he is lonely
; or isolated. A crowded man pursues nobody (the pursuit drivers' own gate).
(define-func social-appetite ()
  (any {@self enthusiasm ?enthusiasm=0.5})
  (any {@self withdrawal ?withdrawal=0.5})
  (* (sociability ?enthusiasm ?withdrawal)
     (cond (case {@self company [k isolated]} (isolated-appetite))
           (case {@self company [k lonely]} (lonely-appetite))
           (else 1.0))))

(define-func run-leisure-drives (?hours ?act)
  (eq ?act SLEEP): ?asleep
  (substantial (any {@self (construed-labels toil-act)})): ?toil
  (substantial (any {@self (construed-labels rest-act)})): ?rest
  (substantial (any {@self (construed-labels play-act)})): ?play
  (social-span): ?social
  (substantial (any {@self (construed-labels sensual-act)})): ?sensual
  (substantial (any {@self (construed-labels devotion-act)})): ?devotion
  (substantial (any {@self (construed-labels exertion-act)})): ?exertion
  (cond (case (none {@self stress ?}) 0.0)
        (else (any {@self stress ?}).target)): ?stress

  (* ?hours (strain-toil-per-hour) (+ 1.0 (* (strain-stress-gain) ?stress))
     (leisure-mult (* (leisure-trait-swing) (+ (- (attr @self volatility) 0.5) (- (attr @self withdrawal) 0.5))))): ?wear
  (* ?hours (- 1.0 (* 0.5 ?stress))
     (+ (flip ?rest (strain-rest-per-hour) 0.0)
        (flip (or ?play ?sensual ?social ?devotion ?exertion) (strain-ease-per-hour) 0.0))): ?ease
  (clamp (- (+ (attr @self strain) (flip ?toil ?wear 0.0)) ?ease) 0.0 1.0): ?strain

  (* ?hours (tedium-per-waking-hour)
     (leisure-mult (* (leisure-trait-swing) (+ (- (attr @self openness) 0.5) (- (attr @self enthusiasm) 0.5)
                                              (- 0.5 (attr @self industriousness)))))): ?dull
  (* ?hours (+ (flip ?play (tedium-play-relief-per-hour) 0.0)
               (flip ?social (tedium-social-relief-per-hour) 0.0)
               (flip ?devotion (tedium-devotion-relief-per-hour) 0.0))): ?stir
  (clamp (+ (attr @self tedium) (flip ?asleep (- 0.0 (* ?hours (tedium-sleep-relief-per-hour))) (- ?dull ?stir))) 0.0 1.0): ?tedium

  (attr @self social-hunger): ?was
  (cond (case ?asleep ?was)
        (case ?social (company-relief ?was ?hours (company-warmth)
                                      (sociability (attr @self enthusiasm) (attr @self withdrawal))))
        (case (< ?was 0.0) (min 0.0 (+ ?was (* ?hours (solitude-recovery-per-hour)
                                                (leisure-mult (* (leisure-trait-swing)
                                                                 (- (attr @self withdrawal) (attr @self enthusiasm))))))))
        (else (min 1.0 (+ ?was (* ?hours (social-hunger-per-waking-hour)
                                  (leisure-mult (* (leisure-trait-swing) (- (attr @self enthusiasm) 0.5)))))))): ?social-hunger

  (set-attr @self strain ?strain)
  (set-attr @self tedium ?tedium)
  (set-attr @self social-hunger ?social-hunger)
  (emit-leisure-bands ?strain ?tedium ?social-hunger))

; A night's sleep takes most of his crowding away: an introvert wakes still carrying more of it.
(define-func /sleep restore-company ()
  (attr @self social-hunger): ?was
  (clamp (* (sleep-crowding-kept)
            (- (sociability-max) (sociability (attr @self enthusiasm) (attr @self withdrawal))))
         0.0 1.0): ?kept
  (flip (< ?was 0.0) (* ?was ?kept) ?was): ?rested
  (set-attr @self social-hunger ?rested)
  (emit-leisure-bands (attr @self strain) (attr @self tedium) ?rested))

(define-func morning-leisure-drives ()
  (set-attr @self strain 0.0)
  (set-attr @self tedium 0.0)
  (set-attr @self social-hunger 0.0)
  (emit-leisure-bands 0.0 0.0 0.0))
