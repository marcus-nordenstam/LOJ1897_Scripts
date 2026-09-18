; TILT_BACK_HEAD - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self TILT_BACK_HEAD ?target}
  (motor head)
  (obs)
  (tar @excl)
  (presentation
    (anim right_drink)
    (anim-flags loop reset)
    (preroll 0.0) (in 0.3) (out 0.7)))
