(think classify-christian-identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?}
    (effects
      (mint-band {@self identity} (prob {@self member-of [k church-org]})
        [k christian-role] 0.5))))
