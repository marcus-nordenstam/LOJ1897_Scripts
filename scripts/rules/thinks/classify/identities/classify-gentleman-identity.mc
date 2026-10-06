(think classify-gentleman-identity
  (rng-stream behaviour)
  (role @self {@self gender ?gender}
              {@self class-situation ?}
    (effects
      (mint-band {@self identity}
        (* (= ?gender [k male])
           (clamp (+ (prob {@self class-situation [k middle]})
                     (prob {@self class-situation [k upper]})) 0.0 1.0))
        [k gentleman-role] 0.5))))
