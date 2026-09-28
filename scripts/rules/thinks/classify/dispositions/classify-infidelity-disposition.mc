; infidelity-disposition - the CHARACTER-cheater's straying tail: narcissistic supply-hunger
; + psychopathic thrill / low empathy + volatile impulsivity. A pure personality read - no
; family, marital or decorum term - so a serial cheater strays whatever their home life.
(think classify-infidelity-disposition
  (cooldown 1 m try-once)
  (role @self {@self narcissism ?narcissism}
              {@self psychopathy ?psychopathy}
              {@self volatility ?volatility}
    (effects
      (begin-belief {@self infidelity-disposition
                     (* 0.3333 (+ ?narcissism ?psychopathy ?volatility))}))))
