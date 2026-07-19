; ----------------------------------------------------------------------------
; devoutness (classifier) - the observance reading banded to the piety_band kinds.
; Recency-weighted worship-episode evidence: a monthly churchgoer saturates devout,
; a quarterly attender reads observant, a 2-year lapse decays through observant to
; secular. The floor band (secular) means every derived NPC carries a reading. @self
; bands its OWN worship memory; a tracked other is banded from the worship episodes
; THIS mind holds of them (witnessed / heard) - the church-going pretender fools it
; by design. (evidence ...) is per-observer and non-telepathic.
; ----------------------------------------------------------------------------

(npc-think classify_self_devoutness
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (believes {@self class_situation ?}))

  (cont-fire-effects
    (mint-band {@self devoutness} (evidence @self worship 6 6)
      [k piety_band devout] 0.55 [k piety_band observant] 0.15 [k piety_band secular] -1)))

(npc-think classify_others_devoutness
  (sim-window-think)
  (rng-stream behaviour)

  (role ?other (believes {?other class_situation ?}))

  (cont-fire-effects
    (mint-band-about {?other devoutness} (evidence ?other worship 6 6)
      [k piety_band devout] 0.55 [k piety_band observant] 0.15 [k piety_band secular] -1)))
