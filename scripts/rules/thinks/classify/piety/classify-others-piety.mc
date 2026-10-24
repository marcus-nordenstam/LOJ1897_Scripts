(think classify-others-piety
  ; Monthly cooldown (like the self side): (evidence ...) decays continuously between the ?other's
  ; witnessed worship episodes, so no belief edge marks the band change - a periodic recompute
  ; re-bands every ?other he knows to have worshipped. A man never known to worship holds no band.
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (role ?other {?other WORSHIP /ever}
               (neq ?other @self)

    (effects
      (mint-band-about {?other piety} (evidence ?other WORSHIP 6 6)
        [k devout] 0.55 [k observant] 0.15 [k secular] -1))))
