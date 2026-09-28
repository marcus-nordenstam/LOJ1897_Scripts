; undeserving-poor: poor/destitute + disreputable.
(think classify-undeserving-poor
  (rng-stream behaviour)
  (role @self {@self economic-situation ?}
    (effects
      (mint-band {@self prototype}
        (* (clamp (+ (prob {@self economic-situation [k economic-situation poor]})
                     (prob {@self economic-situation [k economic-situation destitute]})) 0.0 1.0)
           (clamp (+ (prob {@self repute [k repute disreputable]})
                     (prob {@self repute [k repute scandalous]})) 0.0 1.0))
        [k prototype undeserving-poor] 0.5))))
