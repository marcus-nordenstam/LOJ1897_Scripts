; DEAD_IDLE - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self DEAD_IDLE ?target}
  (duration procedural)
  (motor legs)
  (internal)
  (tar @excl)
  (presentation
    (anim-male Male_Death_Pose)
    (anim-female Female_Death_Pose)
    (anim-flags reset)
    (state dead)
    (preroll 0.0) (in 0.2) (out 0.0)))
