; nouveau-riche: high wealth (>= 0.60) carried by low breeding (<= 0.35).
(think classify-nouveau-riche
  ; wealth re-derives annually; breeding is birth-seeded (an inert input, kept to document it).
  ; The toggle drops if wealth is retracted.
  (rng-stream behaviour)
  (role @self {@self wealth ?wealth} {@self breeding ?breeding}
    (effects
      (mint-band {@self prototype}
        (* (>= ?wealth 0.60)
           (<= ?breeding 0.35))
        [k prototype nouveau-riche] 0.5))))
