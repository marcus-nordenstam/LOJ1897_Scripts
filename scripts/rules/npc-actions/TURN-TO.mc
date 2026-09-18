; TURN-TO - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self TURN-TO ?target}
  (duration procedural)
  (motor legs)
  (obs)
  (tar @excl)
  (presentation
    (anim-male Motion_Male_Idle_02)
    (anim-female Motion_Female_Idle_01)
    (anim-flags pingpong reset randomize_start)
    (delib-turn-speed 6.0)
    (preroll 0.0) (in 0) (out 0)))
