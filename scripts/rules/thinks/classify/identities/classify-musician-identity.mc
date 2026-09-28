(think classify-musician-identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?}
    (effects (mint-band {@self identity} (competent-in [k music])
               [k role musician-role] 0.5))))
