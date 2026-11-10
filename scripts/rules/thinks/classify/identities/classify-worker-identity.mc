; worker: holds a job.
(think classify-worker-identity
  (rng-stream behaviour)
  (belief {@self class-situation ?}
    (effects (mint-band {@self identity} (prob {@self job ?}) [k worker-role] 0.5))))
