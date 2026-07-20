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
  ; Monthly cooldown: (evidence ...) is a recency-weighted fold that DECAYS continuously between
  ; worship episodes (a lapsing churchgoer slides devout->observant->secular purely by the clock),
  ; so no belief edge marks the band change - only a periodic recompute catches it. Once-per-window
  ; keeps it as fresh as the legacy monthly fire, self-primed by cold_start_window. (The
  ; about-others classifier below stays on legacy cont-fire: per-observer re-classification needs
  ; a subject-aware trigger seam - deferred.)
  (schedule cooldown 1 m)
  (if-blocked hold)
  (rng-stream behaviour)

  (role @self (believes {@self class_situation ?}))

  (cont-fire-effects
    (mint-band {@self devoutness} (evidence @self worship 6 6)
      [k piety_band devout] 0.55 [k piety_band observant] 0.15 [k piety_band secular] -1)))

(npc-think classify_others_devoutness
  ; Monthly cooldown (like the self side): (evidence ...) decays continuously between the ?other's
  ; witnessed worship episodes, so no belief edge marks the band change - a periodic recompute
  ; re-bands every tracked ?other from what @self currently holds of their observance.
  (schedule cooldown 1 m)
  (if-blocked hold)
  (rng-stream behaviour)

  (role ?other (believes {?other class_situation ?}))

  (effects
    (mint-band-about {?other devoutness} (evidence ?other worship 6 6)
      [k piety_band devout] 0.55 [k piety_band observant] 0.15 [k piety_band secular] -1)))
