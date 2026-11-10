(think classify-musician-identity
  (rng-stream behaviour)
  (belief {@self class-situation ?}
    (effects (mint-band {@self identity} (competent-in [k music])
               [k musician-role] 0.5))))
