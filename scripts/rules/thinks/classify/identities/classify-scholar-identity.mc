; scholar: a scholarly academic-field, EXCLUDING the two general-schooling tiers -
; a secondary graduate is not a scholar.
(think classify-scholar-identity
  (rng-stream behaviour)
  (role @self {@self class-situation ?}
    (effects
      (mint-band {@self identity}
        (* (competent-in [k academic-field])
           (- 1.0 (competent-in [k primary-school-curriculum]))
           (- 1.0 (competent-in [k secondary-school-curriculum])))
        [k role scholar-role] 0.5))))
