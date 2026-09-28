; worker: holds a job.
(think classify-worker-identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?}
    (effects (mint-band {@self identity} (prob {@self job ?}) [k role worker-role] 0.5))))
