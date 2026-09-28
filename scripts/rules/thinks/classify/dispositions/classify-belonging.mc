; belonging - how well warmth bonds + immediate kin meet the sociability need. Warmth = friends
; (close-to / friend) + kin (spouse x2, children capped 5, parents capped 2, siblings capped 4).
; Need = 1 + Extraversion x 5 (Extraversion = the mean of enthusiasm + assertiveness);
; belonging falls 0.18 per unit of unmet need.
(think classify-belonging
  (cooldown 1 m try-once)
  (role @self {@self enthusiasm ?enthusiasm}
              {@self assertiveness ?assertiveness}
    (effects
      (begin-belief {@self belonging
                     (clamp (- 1.0 (* (max (- (+ 1.0 (* (* (+ ?enthusiasm ?assertiveness) 0.5) 5.0))
                                              (+ (count (every {@self close-to ?}) /float)
                                                 (count (every {@self friend ?}) /float)
                                                 (* 2.0 (prob {@self spouse ?}))
                                                 (min (count (every {@self child ?}) /float) 5.0)
                                                 (min (+ (count (every {@self mother ?}) /float)
                                                         (count (every {@self father ?}) /float)) 2.0)
                                                 (min (+ (count (every {@self sibling ?}) /float)
                                                         (count (every {@self half-sibling ?}) /float)) 4.0)))
                                          0.0) 0.18)) 0.0 1.0)}))))
