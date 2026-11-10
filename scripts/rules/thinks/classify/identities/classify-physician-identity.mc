(think classify-physician-identity
  (rng-stream behaviour)
  (belief {@self class-situation ?}
    (effects (mint-band {@self identity} (competent-in [k medicine])
               [k physician-role] 0.5))))
