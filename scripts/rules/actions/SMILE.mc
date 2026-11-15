; SMILE - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (init ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(action {@self SMILE ?target}
  (belief-timeout 1 min)
  (duration procedural)
  (motor face)
  (tar @excl)
  (presentation
    (expression smile_neutral.esp)
    (preroll 0.0) (in 0.2) (out 0.2)))
