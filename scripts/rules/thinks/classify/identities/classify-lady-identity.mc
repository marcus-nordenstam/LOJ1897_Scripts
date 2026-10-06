(think classify-lady-identity
  (rng-stream behaviour)
  (role @self {@self gender ?gender}
              {@self class-situation ?}
    (effects
      (mint-band {@self identity}
        (* (= ?gender [k female])
           (clamp (+ (prob {@self class-situation [k middle]})
                     (prob {@self class-situation [k upper]})) 0.0 1.0))
        [k lady-role] 0.5))))
