(think classify-merchant-identity
  (rng-stream behaviour)
  (belief {@self class-situation ?}
    (effects
      (mint-band {@self identity} (prob {@self job [k merchant]})
        [k merchant-role] 0.5))))
