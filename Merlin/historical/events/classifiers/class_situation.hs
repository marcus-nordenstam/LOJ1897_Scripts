; ----------------------------------------------------------------------------
; class_situation (classifier). Bands breeding (the dominant lineage anchor) +
; prestige (public office) + wealth, weights 5/3/2 normalized, into the
; {@self class_situation <band>} belief. A high prestige + wealth carries a
; low-breeding man up a band (the self-made climb); idle high breeding slides
; down. Eventified (mint-band) replacement of the (classify) declaration.
;
; Gated on all three input dimensions being derived (the intra-day agenda's
; conjuncts) - a subject the cascade has not derived yet keeps its seeded band.
; ----------------------------------------------------------------------------

(npc-think classify_class_situation
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (believes {@self breeding ?})
              (believes {@self prestige ?})
              (believes {@self wealth ?}))

  (cont-fire-effects
    (mint-band {@self class_situation}
      (+ (* 0.5 (target {@self breeding}))
         (* 0.3 (target {@self prestige}))
         (* 0.2 (target {@self wealth})))
      [k class_situation upper]  0.70
      [k class_situation middle] 0.40
      [k class_situation lower]  -1)))
