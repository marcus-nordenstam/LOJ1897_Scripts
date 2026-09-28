; skilled path: a martial or garrotting skill IS the capability; mint on reason.
(think classify-for-hire-skilled
  (rng-stream behaviour)
  (role @self {@self compassion ?compassion}
              {@self industriousness ?industriousness}
              {@self politeness ?politeness}
              {@self volatility ?volatility}
              {@self economic-situation ?}
              (or {@self skill-level [k martial]}
                  {@self skill-level [k garrotting]})
    (effects
      (mint-band {@self prototype}
        ; REASON: economic desperation OR the callous + disinhibited bad seed.
        (clamp (+ (clamp (+ (prob {@self economic-situation [k economic-situation poor]})
                            (prob {@self economic-situation [k economic-situation destitute]})) 0.0 1.0)
                  (* (<= ?compassion 0.40)
                     (>= (/ (+ (- 1.0 ?industriousness)
                               (- 1.0 ?politeness)
                               ?volatility) 3.0)
                         0.55))) 0.0 1.0)
        [k prototype for-hire] 0.5))))
