; ----------------------------------------------------------------------------
; devoutness (classifier) - the observance reading banded to the piety-band kinds.
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
  ; so no belief edge marks the band change - only a periodic recompute catches it. Self-primed
  ; by cold_start_window.
  (cooldown 1 m)
  (rng-stream behaviour)

  (role @self {@self class-situation ?})

  (effects
    (mint-band {@self devoutness} (evidence @self WORSHIP 6 6)
      [k piety-band devout] 0.55 [k piety-band observant] 0.15 [k piety-band secular] -1)))

(npc-think classify_others_devoutness
  ; Monthly cooldown (like the self side): (evidence ...) decays continuously between the ?other's
  ; witnessed worship episodes, so no belief edge marks the band change - a periodic recompute
  ; re-bands every tracked ?other from what @self currently holds of their observance.
  (cooldown 1 m)
  (rng-stream behaviour)

  (role ?other {?other class-situation ?})

  (effects
    (mint-band-about {?other devoutness} (evidence ?other WORSHIP 6 6)
      [k piety-band devout] 0.55 [k piety-band observant] 0.15 [k piety-band secular] -1)))
