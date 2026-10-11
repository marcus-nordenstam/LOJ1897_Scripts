; --- profile seeding (one-shot, precedes the first hunt) --------------------
(think seed-predation-profile
  (cooldown 1 m try-once)
  (rng-stream perpetration)
  (role @self {@self psychopathy ?psychopathy}
              {@self sadism ?sadism}
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
              -{@self hair-color-fixation ?}
    ; A random adult the predator KNOWS the look of (has both perceived colour
    ; beliefs about), sampled by roulette - the victim-type prototype.
    (role ?proto {?proto isa [k human], condition [k alive]}
                 {?proto age-band [k young-adult|middle-aged|mature|elderly]}
                 (!= ?proto @self)
                 {?proto hair-color ?hair-color}
                 {?proto eye-color ?eye-color}
                 (select (score 1) (policy roulette))
      ; Only the hard lethal-disposition tail ever seeds (same floor as the hunt).
      (when (>= (* 0.5 (+ ?psychopathy ?sadism)) 0.65))
      (effects
        ; Copy the perceived look as the type signature (effect, so (target ...) is fine).
        (begin-belief {@self hair-color-fixation ?hair-color})
        (begin-belief {@self eye-color-fixation ?eye-color})))))
