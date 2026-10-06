; deserving-poor: poor/destitute + reputable.
(think classify-deserving-poor
  (rng-stream behaviour)
  (role @self {@self economic-situation ?}
    (effects
      (mint-band {@self prototype}
        (* (clamp (+ (prob {@self economic-situation [k poor]})
                     (prob {@self economic-situation [k destitute]})) 0.0 1.0)
           (clamp (+ (prob {@self repute [k exemplary]})
                     (prob {@self repute [k respectable]})) 0.0 1.0))
        [k deserving-poor] 0.5))))
