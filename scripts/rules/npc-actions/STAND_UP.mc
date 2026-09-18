; STAND_UP - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self STAND_UP ?target}
  (motor legs)
  (obs)
  (tar @excl)
  (presentation
    (anim-flags backwards)
    (preroll 0.0) (in 0.4) (out 0.4)))
