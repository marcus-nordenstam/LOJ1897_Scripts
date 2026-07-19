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
; lax the floor. honesty / diligence / generosity / sobriety read the dimensions.hs
; value macros.
; ----------------------------------------------------------------------------

(npc-think classify_self_conduct
  (sim-window-think)
  ; Monthly cooldown, NOT on-commit: sobriety folds the continuously-drifting intoxication attr
  ; (which never edges the belief seam) and the give act-record; a purely edge-driven schedule
  ; would leave those bands stale between the rare belief commits. A once-per-window timer keeps
  ; the conduct bands as fresh as the legacy monthly fire, desynced across the herd, and off the
  ; agenda while cooling. cold_start_window self-primes it (no seed-edge dependency).
  ; (conduct_bands_others.hs stays on legacy cont-fire - about-others reschedule needs a
  ; subject-aware seam, deferred.)
  (schedule cooldown 1 m)
  (if-blocked hold)

  (role @self (believes {@self class_situation ?}))

  (cont-fire-effects
    (mint-band {@self honesty}    (honesty)
      [k conduct_level good] 0.66 [k conduct_level fair] 0.33 [k conduct_level lax] -1)
    (mint-band {@self diligence}  (diligence)
      [k conduct_level good] 0.66 [k conduct_level fair] 0.33 [k conduct_level lax] -1)
    (mint-band {@self generosity} (generosity)
      [k conduct_level good] 0.66 [k conduct_level fair] 0.33 [k conduct_level lax] -1)
    (mint-band {@self sobriety}   (sobriety)
      [k conduct_level good] 0.66 [k conduct_level fair] 0.33 [k conduct_level lax] -1)))
