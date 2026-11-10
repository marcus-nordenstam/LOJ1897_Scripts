(define-macro identity-sadist-min ()        0.65)

(think classify-sadist-identity
  (rng-stream behaviour)
  (belief {@self sadism ?sadism}
              {@self class-situation ?}
    (effects
      (mint-band {@self identity}
        (>= ?sadism (identity-sadist-min))
        [k sadist-role] 0.5))))
