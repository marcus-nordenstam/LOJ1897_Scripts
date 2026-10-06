; parent: holds a child belief.
(think classify-parent-identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?}
    (effects (mint-band {@self identity} (prob {@self child ?}) [k parent-role] 0.5))))
