(think classify-self-piety
  ; Monthly cooldown: (evidence ...) decays continuously between worship episodes, so a lapsing
  ; churchgoer slides devout->observant->secular by the clock alone and only a periodic recompute
  ; catches it. This is his piety as others see it, never his devoutness.
  (cooldown 1 m try-once)
  (rng-stream behaviour)

  (role @self {@self class-situation ?}

    (effects
      (mint-band {@self piety} (evidence @self WORSHIP 6 6)
        [k devout] 0.55 [k observant] 0.15 [k secular] -1))))
