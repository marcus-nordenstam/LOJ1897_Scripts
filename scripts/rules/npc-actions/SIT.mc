; SIT - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (init ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self SIT ?target}
  (duration procedural)
  (motor legs)
  (obs)
  (tar @excl)
  (presentation
    (anim Motion_Uni_Sitting_Talking_01)
    (anim-flags loop reset)
    (state sitting)
    (preroll 0.0) (in 0.4) (out 0.4)))
