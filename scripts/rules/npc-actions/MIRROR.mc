; ----------------------------------------------------------------------------
; MIRROR - @self turns to face the way ?other faces, not to face ?other.
;
; PORTED from the C++ handler (action_unification_plan.md). The distinction is the whole
; act: two men side by side at a counter face the same way, and that is mirroring.
; Same branch as TURN-TO - snap unpresented, swing presented - over (face-as ..)
; instead of (face-toward ..).
; ----------------------------------------------------------------------------

(npc-action {@self MIRROR ?other}:?mirror
  (motor legs)
  (obs)
  (tar @excl)
  (duration procedural)
  (presentation
    (anim-male Motion_Male_Idle_02)
    (anim-female Motion_Female_Idle_01)
    (anim-flags pingpong reset randomize_start)
    (delib-turn-speed 6.0)
    (preroll 0.0) (in 0.0) (out 0.0))

  ; THE UNPRESENTED TURN IS INSTANTANEOUS, so it happens in the PRELUDE and concludes
  ; there. The act is procedural - it has no cap - so nothing would ever tick an
  ; (effects ..) block for an unpresented mind, and a snap that waits for a frame
  ; that never comes is a man who never turns. Presented, the swing takes frames and
  ; belongs in the effects, which the frame loop runs.
  (init
    (cond
      (case (unsubstantial ?other) (set-outcome ?mirror /fail))
      (case (unpresented-lod)
        (face-as @self ?other)
        (set-outcome ?mirror /succ))))

  (effects
    (if (presented-lod)
      (then
        (steer-facing @self ?other)
        (if (is-mirroring @self ?other)
            (then (set-outcome ?mirror /succ)))))))
