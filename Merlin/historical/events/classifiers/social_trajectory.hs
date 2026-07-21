; ----------------------------------------------------------------------------
; social_trajectory (classifier). Bands the divergence of achieved standing
; ((prestige + wealth) / 2) from the inherited breeding anchor into the
; {@self social_trajectory <band>} belief; +/- 0.15 counts as a move. The
; climbing clerk reads rising; the idle high-breeding heir declining.
; ----------------------------------------------------------------------------

(npc-think classify_social_trajectory
  (schedule on-commit)
  (if-blocked hold)
  (rng-stream behaviour)

  (role @self (believes {@self breeding ?})
              (believes {@self prestige ?})
              (believes {@self wealth ?}))

  (effects
    (mint-band {@self social_trajectory}
      (+ (* 0.5 (target {@self prestige}))
         (* 0.5 (target {@self wealth}))
         (* -1  (target {@self breeding})))
      [k social_trajectory rising]    0.15
      [k social_trajectory stable]    -0.15
      [k social_trajectory declining] -2)))
