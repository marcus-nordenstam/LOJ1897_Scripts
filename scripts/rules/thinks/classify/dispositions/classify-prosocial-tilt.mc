; prosocial-tilt - the PROSOCIAL twin: the same dimensions with the signs reversed, so the
; polite and compassionate confess and report where the dark and volatile expose and coerce.
(think classify-prosocial-tilt
  (cooldown 1 d try-once)
  (role @self {@self politeness ?politeness}
              {@self compassion ?compassion}
              {@self volatility ?volatility}
              {@self narcissism ?narcissism}
              {@self machiavellianism ?machiavellianism}
              {@self psychopathy ?psychopathy}
              {@self sadism ?sadism}
    (effects
      (any {@self contentment ?contentment=0.5})
      (any {@self stress ?stress=0.5})
      (any {@self agitation ?agitation=0.5})
      (begin-belief {@self prosocial-tilt
                     (* (clamp (+ 1.0
                                  (- (+ (delib-ctr ?politeness (k-trait-swing))
                                        (delib-ctr ?compassion (k-trait-swing)))
                                     (+ (delib-ctr ?volatility       (k-trait-swing))
                                        (delib-ctr ?narcissism       (k-trait-swing))
                                        (delib-ctr ?machiavellianism (k-trait-swing))
                                        (delib-ctr ?psychopathy      (k-trait-swing))
                                        (delib-ctr ?sadism           (k-trait-swing))))) 0.0 2.0)
                        (clamp (+ 1.0
                                  (- (delib-ctrc ?contentment (k-mood-swing))
                                     (+ (delib-ctrc ?stress    (k-mood-swing))
                                        (delib-ctrc ?agitation (k-mood-swing))))) 0.0 2.0))}))))
