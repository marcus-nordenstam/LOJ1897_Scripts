(think classify-self-repute
  ; The fully-banded fuse over the seven repute-fold terms: four conduct bands +
  ; devoutness + decorum + chastity-scalar (lover count); a band drops when its
  ; evidence is forgotten. class-situation being derived is the eligibility gate,
  ; not a fold input.
  (rng-stream behaviour)

  (role @self {@self class-situation ?}

    (effects
      (mint-band {@self repute} (repute-fold @self)
        [k repute exemplary]    0.80
        [k repute respectable]  0.60
        [k repute questionable] 0.40
        [k repute disreputable] 0.20
        [k repute scandalous]   -1))))
