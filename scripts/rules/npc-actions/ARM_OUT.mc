; ARM_OUT - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self ARM_OUT ?target}
  (duration procedural)
  (sided target left_arm right_arm)
  (obs)
  (tar @excl)
  (presentation
    (anim right_arm_out)
    (anim-flags loop reset)
    (preroll 0.0) (in 1) (out 1)))
