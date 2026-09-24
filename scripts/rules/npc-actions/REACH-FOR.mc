; ----------------------------------------------------------------------------
; REACH-FOR - the arm extends until the hand is at ?target.
;
; PORTED from the C++ handler (action_unification_plan.md). Its init_func also read ?target's
; world bounds and threw the answer away - the read existed to make the bounds-attr
; error fire, which it does on its own wherever the geometry is actually used, so it
; is not ported. The reach is pure timing plus an IK request the animation layer
; builds; success comes from the cap, not from the solver converging.
; ----------------------------------------------------------------------------

(npc-action {@self REACH-FOR ?target ?arm}:?reach
  (lod presented)
  (sided aux left-arm right-arm)
  (obs)
  (tar @excl)
  (duration 0.1)
  (cap-outcome succ)
  (presentation
    (proc-anim reachfor)
    (preroll 0.0) (in 1) (out 1)))
