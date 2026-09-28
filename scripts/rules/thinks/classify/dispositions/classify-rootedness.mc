; rootedness - how established the NPC is in the community. Local lineage (mother / father),
; a spouse, children (each +0.06, capped at 4), a steady occupation, owned property and club
; membership each add a partial score; the sum clamps to 1. ANY held post roots. A
; recently-arrived immigrant with just a job reads low (~0.20); a settled local family high.
(think classify-rootedness
  (cooldown 1 m try-once)
  (role @self {@self age-band ?}
    (effects
      (begin-belief {@self rootedness
                     (clamp (+ (* 0.15 (prob {@self mother ?}))
                               (* 0.15 (prob {@self father ?}))
                               (* 0.20 (prob {@self spouse ?}))
                               (* 0.06 (min (count (every {@self child ?}) /float) 4.0))
                               (* 0.20 (prob {@self job ?}))
                               (* 0.15 (>= (count (every {@self owns-building ?})) 1))
                               (* 0.10 (>= (count (every {@self member-of ?})) 1))) 0.0 1.0)}))))
