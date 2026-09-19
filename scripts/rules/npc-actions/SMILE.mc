; SMILE - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (init ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self SMILE ?target}
  (duration procedural)
  (motor face)
  (obs)
  (tar @excl)
  (presentation
    (expression smile_neutral.esp)
    (preroll 0.0) (in 0.2) (out 0.2)))
