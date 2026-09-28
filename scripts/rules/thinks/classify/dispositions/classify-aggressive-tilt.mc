; aggressive-tilt - the 1.0-centered multiplier an AGGRESSIVE outlet rides: dark tetrad +
; volatility amplify, politeness + compassion damp; the mood overlay rides a smaller swing on
; top. Each half clamps to [0, 2], so the product spans [0, 4].
(think classify-aggressive-tilt
  (cooldown 1 d try-once)
  (role @self {@self narcissism ?narcissism}
              {@self machiavellianism ?machiavellianism}
              {@self psychopathy ?psychopathy}
              {@self sadism ?sadism}
              {@self volatility ?volatility}
              {@self politeness ?politeness}
              {@self compassion ?compassion}
    (effects
      (any {@self stress ?stress=0.5})
      (any {@self agitation ?agitation=0.5})
      (any {@self contentment ?contentment=0.5})
      (begin-belief {@self aggressive-tilt
                     (* (clamp (+ 1.0
                                  (- (+ (delib-ctr ?narcissism       (k-trait-swing))
                                        (delib-ctr ?machiavellianism (k-trait-swing))
                                        (delib-ctr ?psychopathy      (k-trait-swing))
                                        (delib-ctr ?sadism           (k-trait-swing))
                                        (delib-ctr ?volatility       (k-trait-swing)))
                                     (+ (delib-ctr ?politeness (k-trait-swing))
                                        (delib-ctr ?compassion (k-trait-swing))))) 0.0 2.0)
                        (clamp (+ 1.0
                                  (- (+ (delib-ctrc ?stress    (k-mood-swing))
                                        (delib-ctrc ?agitation (k-mood-swing)))
                                     (delib-ctrc ?contentment (k-mood-swing)))) 0.0 2.0))}))))
