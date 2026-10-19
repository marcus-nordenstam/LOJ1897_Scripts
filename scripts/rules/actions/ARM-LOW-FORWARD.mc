; ?target only names the side: (side ?x), or [k left] / [k right].

(action {@self ARM-LOW-FORWARD ?target}
  (duration procedural)
  (sided target left-arm right-arm)
  (obs)
  (tar @excl)
  (presentation
    (anim-right right_arm_out)
    (anim-flags loop reset)
    (preroll 0.0) (in 1) (out 1)))
