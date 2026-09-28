; deserving-poor: poor/destitute + reputable.
(think classify-deserving-poor
  (rng-stream behaviour)
  (role @self {@self economic-situation ?}
    (effects
      (mint-band {@self prototype}
        (* (clamp (+ (prob {@self economic-situation [k economic-situation poor]})
                     (prob {@self economic-situation [k economic-situation destitute]})) 0.0 1.0)
           (clamp (+ (prob {@self repute [k repute exemplary]})
                     (prob {@self repute [k repute respectable]})) 0.0 1.0))
        [k prototype deserving-poor] 0.5))))
