(think classify-christian-identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?}
    (effects
      (mint-band {@self identity} (prob {@self member-of [k org gov church]})
        [k role christian-role] 0.5))))
