(think classify-self-repute
  ; The fully-banded fuse over the seven repute-fold terms: four conduct bands +
  ; devoutness + decorum + chastity-scalar (lover count); a band drops when its
  ; evidence is forgotten. class-situation being derived is the eligibility gate,
  ; not a fold input.
  (rng-stream behaviour)

  (role @self {@self class-situation ?}

    (effects
      (mint-band {@self repute} (repute-fold @self)
        [k exemplary]    0.80
        [k respectable]  0.60
        [k questionable] 0.40
        [k disreputable] 0.20
        [k scandalous]   -1))))
