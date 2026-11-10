(think classify-soldier-identity
  (rng-stream behaviour)
  (belief {@self class-situation ?}
    (effects (mint-band {@self identity} (competent-in [k martial])
               [k soldier-role] 0.5))))
