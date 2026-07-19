; ----------------------------------------------------------------------------
; repute (per-observer). Each mind bands a person's public respectability into
; {X repute [k respectability_situation ...]} from (repute-fold X) - the seven-term
; mean over that person's conduct bands + devoutness + decorum + per-observer chastity
; (dimensions.hs). ONE fold serves both:
;   - classify_self_repute:   {@self repute}   from @self's OWN conduct (mint-band).
;   - classify_others_repute: {?other repute}  from what @self knows of them
;                             (mint-band-about, in @self's own pool).
;
; Reputation is per-observer: two people can hold different repute beliefs about the
; same third party, and a stranger reads middling (fair defaults). An observer with
; only negative evidence caps a person below exemplary - you do not credit a
; prestige-marriage-grade character to someone you know nothing good about. (Bands:
; the historical respectability thresholds.)
; ----------------------------------------------------------------------------

(npc-think classify_self_repute
  (sim-window-think)
  ; on-changed: the fully-banded fuse recomputes when any conduct band toggles (a band drops
  ; when its evidence is forgotten). Triggers = the four conduct bands + devoutness + decorum
  ; + lover (chastity-scalar) + class_situation (gate). These are the exact repute-fold inputs.
  ; (classify_others_repute below stays on legacy cont-fire - about-others reschedule deferred.)
  (schedule on-changed {@self honesty ?} {@self diligence ?} {@self generosity ?}
                       {@self sobriety ?} {@self devoutness ?} {@self decorum ?}
                       {@self lover ?} {@self class_situation ?})
  (if-blocked hold)
  (rng-stream behaviour)

  (role @self (believes {@self class_situation ?}))

  (cont-fire-effects
    (mint-band {@self repute} (repute-fold @self)
      [k respectability_situation exemplary]    0.80
      [k respectability_situation respectable]  0.60
      [k respectability_situation questionable] 0.40
      [k respectability_situation disreputable] 0.20
      [k respectability_situation scandalous]   -1)))

(npc-think classify_others_repute
  (sim-window-think)
  (rng-stream behaviour)

  (role ?other (believes {?other class_situation ?}))

  (cont-fire-effects
    (mint-band-about {?other repute} (repute-fold ?other)
      [k respectability_situation exemplary]    0.80
      [k respectability_situation respectable]  0.60
      [k respectability_situation questionable] 0.40
      [k respectability_situation disreputable] 0.20
      [k respectability_situation scandalous]   -1)))
