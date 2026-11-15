; DIAGNOSE - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (init ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(action {@self DIAGNOSE ?target}
  (belief-timeout 30 min)
  (duration procedural)
  (motor eyes)
  (tar @excl)
  (presentation
    (preroll 0.0) (in 0.5) (out 0.5)))
