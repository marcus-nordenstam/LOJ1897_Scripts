; RUN - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (init ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self RUN ?target}
  (duration procedural)
  (motor legs)
  (obs)
  (tar @excl)
  (presentation
    (anim-male Motion_Male_Run_01)
    (anim-female Motion_Fem_Run_01)
    (anim-flags loop reset)
    (state running)
    (movement-speed 0.5)
    (delib-turn-speed 12.0)
    (preroll 0) (in 0) (out 0)))
