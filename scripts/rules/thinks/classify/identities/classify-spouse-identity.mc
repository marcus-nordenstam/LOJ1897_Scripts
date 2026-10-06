; spouse: married.
(think classify-spouse-identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?}
    (effects (mint-band {@self identity} (prob {@self spouse ?}) [k spouse-role] 0.5))))
