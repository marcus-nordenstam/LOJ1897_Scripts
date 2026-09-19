; ----------------------------------------------------------------------------
; JUMP ?target - both feet leave the ground once.
;
; PORTED from the C++ handler, whose whole body was an impulse fired ONCE at install if
; the man was standing on something: run_func was a no-op and the bounded cap committed
; the success. So the port is a prelude and a duration, and the impulse crosses to the
; game because it is the physics controller's - an unpresented man has no ground to
; push off and simply spends the second.
; ----------------------------------------------------------------------------

(npc-action {@self JUMP ?target}:?jump
  (motor legs)
  (obs)
  (tar @excl)
  (duration 1.0)
  (cap-outcome succ)
  (presentation
    (preroll 0.0) (in 0.1) (out 0.1))

  (init
    (if (presented-lod)
        (then (jump-impulse @self)))))
