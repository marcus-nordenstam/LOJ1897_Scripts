; TILT-BACK-HEAD - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (init ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self TILT-BACK-HEAD ?target}
  (duration procedural)
  (motor head)
  (obs)
  (tar @excl)
  (presentation
    (anim right_drink)
    (anim-flags loop reset)
    (preroll 0.0) (in 0.3) (out 0.7)))
