; artist: a performance art that is NOT music (a musician is not a generic artist).
(think classify-artist-identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?}
    (effects
      (mint-band {@self identity}
        (* (competent-in [k performance-art]) (- 1.0 (competent-in [k music])))
        [k artist-role] 0.5))))
