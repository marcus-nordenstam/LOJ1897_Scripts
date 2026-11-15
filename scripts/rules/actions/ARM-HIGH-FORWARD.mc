; ?target only names the side: (side ?x), or [k left] / [k right].

(action {@self ARM-HIGH-FORWARD ?target}
  (belief-timeout 1 min)
  (duration procedural)
  (sided target left-arm right-arm)
  (tar @excl)
  (presentation
    (anim-left Left_Lantern_Hold)
    (anim-flags loop reset)
    (preroll 0.0) (in 1) (out 1)))
