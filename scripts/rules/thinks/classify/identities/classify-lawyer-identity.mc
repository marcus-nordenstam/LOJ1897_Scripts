(think classify-lawyer-identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?}
    (effects (mint-band {@self identity} (competent-in [k law])
               [k role lawyer-role] 0.5))))
