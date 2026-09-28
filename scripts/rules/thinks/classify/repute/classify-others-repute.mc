(think classify-others-repute
  ; Per-observer fuse: re-bands ?other's repute from the conduct band / devoutness /
  ; decorum / lover beliefs @self holds ABOUT them. class-situation is the gate.
  (rng-stream behaviour)

  (role ?other {?other class-situation ?}

    (effects
      (mint-band-about {?other repute} (repute-fold ?other)
        [k repute exemplary]    0.80
        [k repute respectable]  0.60
        [k repute questionable] 0.40
        [k repute disreputable] 0.20
        [k repute scandalous]   -1))))
