; ----------------------------------------------------------------------------
; TURN-TO - @self turns on the spot until he faces ?target.
;
; PORTED from the C++ handler (action_unification_plan.md). ONE ALGORITHM, ONE BRANCH,
; and the branch is at the write: unpresented SNAPS the box round and is done in that
; instant, presented swings the body at its turn rate over as many frames as it takes.
; The handler's own shape exactly - the whole of its unpresented path was a yaw write
; and a success, and its presented path was Turn() and no outcome.
; ----------------------------------------------------------------------------

(npc-action {@self TURN-TO ?target}:?turn
  (motor legs)
  (obs)
  (tar @excl)
  (duration procedural)
  (presentation
    (anim-male Motion_Male_Idle_02)
    (anim-female Motion_Female_Idle_01)
    (anim-flags pingpong reset randomize_start)
    (delib-turn-speed 6.0)
    (preroll 0.0) (in 0) (out 0))

  ; THE UNPRESENTED TURN IS INSTANTANEOUS, so it happens in the PRELUDE and concludes
  ; there. The act is procedural - it has no cap - so nothing would ever tick an
  ; (effects ..) block for an unpresented mind, and a snap that waits for a frame
  ; that never comes is a man who never turns. Presented, the swing takes frames and
  ; belongs in the effects, which the frame loop runs.
  (init
    (cond
      (case (unsubstantial ?target) (set-outcome ?turn /fail))
      (case (unpresented-lod)
        (face-toward @self ?target)
        (set-outcome ?turn /succ))))

  (effects
    (if (presented-lod)
      (then
        ; No outcome: the swing takes frames, and he is done when he is facing it.
        (steer-facing @self ?target)
        (if (is-facing @self ?target)
            (then (set-outcome ?turn /succ)))))))
