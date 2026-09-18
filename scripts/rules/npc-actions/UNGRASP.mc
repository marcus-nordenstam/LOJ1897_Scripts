; UNGRASP - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self UNGRASP ?target}
  (duration 0)
  (sided target left-hand right-hand)
  (obs)
  (tar @excl)
  (presentation
    (preroll 0.0) (in 0.05) (out 0.05)))
