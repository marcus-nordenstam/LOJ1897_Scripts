; HANG-HEAD - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (init ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(action {@self HANG-HEAD ?target}
  (belief-timeout 1 min)
  (duration procedural)
  (motor head)
  (tar @excl)
  (presentation
    (anim hang_head)
    (anim-flags loop reset)
    (preroll 0.0) (in 0.2) (out 0.2)))
