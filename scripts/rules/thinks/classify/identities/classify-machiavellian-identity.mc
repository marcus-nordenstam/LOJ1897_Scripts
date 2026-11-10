(define-macro identity-machiavellian-min () 0.65)

(think classify-machiavellian-identity
  (rng-stream behaviour)
  (belief {@self machiavellianism ?machiavellianism}
              {@self class-situation ?}
    (effects
      (mint-band {@self identity}
        (>= ?machiavellianism (identity-machiavellian-min))
        [k machiavellian-role] 0.5))))
