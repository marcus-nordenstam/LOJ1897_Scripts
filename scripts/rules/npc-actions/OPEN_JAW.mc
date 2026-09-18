; OPEN_JAW - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self OPEN_JAW ?target}
  (duration 1.0)
  (motor mouth)
  (obs)
  (tar @excl)
  (presentation
    (proc-anim open_jaw)
    (preroll 0.0) (in 0.6) (out 0.9)))
