; CRY_EXPR - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self CRY_EXPR ?target}
  (duration procedural)
  (motor face)
  (obs)
  (tar @excl)
  (presentation
    (expression Scene_01_CryingLady_X_008.esp)
    (preroll 0.0) (in 0.2) (out 0.2)))
