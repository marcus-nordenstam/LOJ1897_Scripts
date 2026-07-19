; ----------------------------------------------------------------------------
; Conduct bands (per-observer repute layer, SELF side). Bands @self's own conduct
; dimensions into {@self <dim> [k conduct_level ...]} beliefs so the per-observer
; repute fuse can read a uniform banded belief for @self AND for a tracked other.
; @self reads its OWN dims (honest self-image, no telepathy); the OTHER side
; (conduct_bands_others.hs) abduces {?other <dim> <level>} from what it witnessed.
;
; Four dims band here (honesty / diligence / generosity / sobriety); the fuse's
; remaining terms come from elsewhere - piety from {X devoutness} (the about-others
; classifier, already per-observer), decorum from the {X decorum} float, and chastity
; on demand from (count-beliefs-about X lover). Bands: good >= 0.66, fair >= 0.33,
; lax the floor. Values read via (classifier-value ...) for now (the honesty /
; diligence / generosity / sobriety value classifiers are still catalog-declared;
; they become dimensions.hs macros in a later value-dim cleanup).
; ----------------------------------------------------------------------------

(npc-think classify_self_conduct
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (believes {@self class_situation ?}))

  (cont-fire-effects
    (mint-band {@self honesty}    (classifier-value honesty)
      [k conduct_level good] 0.66 [k conduct_level fair] 0.33 [k conduct_level lax] -1)
    (mint-band {@self diligence}  (classifier-value diligence)
      [k conduct_level good] 0.66 [k conduct_level fair] 0.33 [k conduct_level lax] -1)
    (mint-band {@self generosity} (classifier-value generosity)
      [k conduct_level good] 0.66 [k conduct_level fair] 0.33 [k conduct_level lax] -1)
    (mint-band {@self sobriety}   (classifier-value sobriety)
      [k conduct_level good] 0.66 [k conduct_level fair] 0.33 [k conduct_level lax] -1)))
