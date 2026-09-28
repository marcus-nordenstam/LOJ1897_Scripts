(think classify-others-devoutness
  ; Monthly cooldown (like the self side): (evidence ...) decays continuously between the ?other's
  ; witnessed worship episodes, so no belief edge marks the band change - a periodic recompute
  ; re-bands every tracked ?other from what @self currently holds of their observance.
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (role ?other {?other class-situation ?}

    (effects
      (mint-band-about {?other devoutness} (evidence ?other WORSHIP 6 6)
        [k piety-band devout] 0.55 [k piety-band observant] 0.15 [k piety-band secular] -1))))
