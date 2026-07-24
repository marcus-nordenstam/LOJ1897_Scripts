; ----------------------------------------------------------------------------
; class_situation (classifier). Bands breeding (the dominant lineage anchor) +
; prestige (public office) + wealth, weights 5/3/2 normalized, into the
; {@self class_situation <band>} belief. A high prestige + wealth carries a
; low-breeding man up a band (the self-made climb); idle high breeding slides
; down.
;
; Gated on all three input dimensions being derived (the role's self-belief
; conjuncts) - a subject the cascade has not derived yet keeps its seeded band.
; ----------------------------------------------------------------------------

(npc-think classify_class_situation
  (rng-stream behaviour)

  (role @self (believes {@self breeding ?breeding})
              (believes {@self prestige ?prestige})
              (believes {@self wealth ?wealth}))

  (effects
    (mint-band {@self class_situation}
      (+ (* 0.5 ?breeding)
         (* 0.3 ?prestige)
         (* 0.2 ?wealth))
      [k class_situation upper]  0.70
      [k class_situation middle] 0.40
      [k class_situation lower]  -1)))
