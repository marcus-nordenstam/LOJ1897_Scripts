(think classify-self-devoutness
  ; Monthly cooldown: (evidence ...) is a recency-weighted fold that DECAYS continuously between
  ; worship episodes (a lapsing churchgoer slides devout->observant->secular purely by the clock),
  ; so no belief edge marks the band change - only a periodic recompute catches it. Self-primed
  ; by cold_start_window.
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (role @self {@self class-situation ?}

    (effects
      (mint-band {@self devoutness} (evidence @self WORSHIP 6 6)
        [k piety-band devout] 0.55 [k piety-band observant] 0.15 [k piety-band secular] -1))))
