; undeserving-poor: poor/destitute + disreputable.
(think classify-undeserving-poor
  (rng-stream behaviour)
  (role @self {@self economic-situation ?}
    (effects
      (mint-band {@self prototype}
        (* (clamp (+ (prob {@self economic-situation [k poor]})
                     (prob {@self economic-situation [k destitute]})) 0.0 1.0)
           (clamp (+ (prob {@self repute [k disreputable]})
                     (prob {@self repute [k scandalous]})) 0.0 1.0))
        [k undeserving-poor] 0.5))))
