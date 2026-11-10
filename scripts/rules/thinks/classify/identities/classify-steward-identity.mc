(think classify-steward-identity
  (rng-stream behaviour)
  (belief {@self class-situation ?}
    (effects
      (mint-band {@self identity} (prob {@self job [k steward]})
        [k steward-role] 0.5))))
