; brute path: the lower-class strong man with NO lethal skill (footpad / cosh thug).
(think classify-for-hire-brute
  (rng-stream behaviour)
  (role @self {@self strength ?strength}
              {@self compassion ?compassion}
              {@self industriousness ?industriousness}
              {@self politeness ?politeness}
              {@self volatility ?volatility}
              {@self economic-situation ?, class-situation ?}
              -{@self skill-level [k martial]}
              -{@self skill-level [k garrotting]}
    (effects
      (mint-band {@self prototype}
        (* (>= ?strength 0.65)
           (prob {@self class-situation [k class-situation lower]})
           (clamp (+ (clamp (+ (prob {@self economic-situation [k economic-situation poor]})
                               (prob {@self economic-situation [k economic-situation destitute]})) 0.0 1.0)
                     (* (<= ?compassion 0.40)
                        (>= (/ (+ (- 1.0 ?industriousness)
                                  (- 1.0 ?politeness)
                                  ?volatility) 3.0)
                            0.55))) 0.0 1.0))
        [k prototype for-hire] 0.5))))
