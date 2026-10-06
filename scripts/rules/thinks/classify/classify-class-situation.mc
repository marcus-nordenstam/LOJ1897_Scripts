; ----------------------------------------------------------------------------
; class-situation (classifier). Bands breeding (the dominant lineage anchor) +
; prestige (public office) + wealth, weights 5/3/2 normalized, into the
; {@self class-situation <band>} belief. A high prestige + wealth carries a
; low-breeding man up a band (the self-made climb); idle high breeding slides
; down.
;
; Gated on all three input dimensions being derived (the role's self-belief
; conjuncts) - a subject the cascade has not derived yet keeps its seeded band.
; ----------------------------------------------------------------------------

(think classify-class-situation
  (rng-stream behaviour)

  (role @self {@self breeding ?breeding}
              {@self prestige ?prestige}
              {@self wealth ?wealth}

    (effects
      (mint-band {@self class-situation}
        (+ (* 0.5 ?breeding)
           (* 0.3 ?prestige)
           (* 0.2 ?wealth))
        [k upper]  0.70
        [k middle] 0.40
        [k lower]  -1))))
