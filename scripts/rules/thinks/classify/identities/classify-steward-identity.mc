(think classify-steward-identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?}
    (effects
      (mint-band {@self identity} (prob {@self job [k steward]})
        [k role steward-role] 0.5))))
