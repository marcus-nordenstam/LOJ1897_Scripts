; piety - worship-episode observance mapped onto the historical piety anchors: 0.25 the
; never-worships floor, 0.85 the regular-churchgoer ceiling. Observance is the
; recency-weighted mass of the subject's OWN worship memories.
(think classify-piety
  (cooldown 1 m try-once)
  (role @self {@self age-band ?}
    (effects
      (begin-belief {@self piety (clamp (+ 0.25 (* (evidence @self WORSHIP 6 6) 0.60)) 0.0 1.0)}))))
