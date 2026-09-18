; JUMP - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self JUMP ?target}
  (duration 1.0)
  (motor legs)
  (obs)
  (tar @excl)
  (presentation
    (preroll 0.0) (in 0.1) (out 0.1)))
