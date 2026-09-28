; inhibition - the moral / conscientious brake on pressure-driven impulse. A weighted fold of
; politeness / industriousness / compassion / piety / decorum minus the disinhibition
; trait-fold (low industriousness + low politeness + high volatility) / stress, with the
; above-population-mean dark-tetrad terms (the one-sided amplification convention) and the
; held-value / justification counts. decorum and stress read 0 until they are derived.
(think classify-inhibition
  (cooldown 1 d try-once)
  (role @self {@self politeness ?politeness}
              {@self industriousness ?industriousness}
              {@self compassion ?compassion}
              {@self volatility ?volatility}
              {@self narcissism ?narcissism}
              {@self machiavellianism ?machiavellianism}
              {@self psychopathy ?psychopathy}
              {@self sadism ?sadism}
    (effects
      (any {@self piety ?piety=0.25})
      (any {@self decorum ?decorum=0.0})
      (any {@self stress ?stress=0.0})
      (begin-belief {@self inhibition
                     (clamp (+ (+ (* ?politeness      0.30)
                                  (* ?industriousness 0.30)
                                  (* ?compassion      0.15)
                                  (* ?piety           0.20)
                                  (* ?decorum         0.10)
                                  (* (/ (+ (- 1.0 ?industriousness) (- 1.0 ?politeness) ?volatility) 3.0) -0.20)
                                  (* ?stress -0.30))
                               (+ (* (clamp (+ ?narcissism       -0.5) 0.0 1.0) -0.10)
                                  (* (clamp (+ ?machiavellianism -0.5) 0.0 1.0) -0.15)
                                  (* (clamp (+ ?psychopathy      -0.5) 0.0 1.0) -0.20)
                                  (* (clamp (+ ?sadism           -0.5) 0.0 1.0) -0.25)
                                  (* (count (every {@self value ?}) /float)    0.05)
                                  (* (count (every {@self justify ?}) /float) -0.08))) 0.0 1.0)}))))
