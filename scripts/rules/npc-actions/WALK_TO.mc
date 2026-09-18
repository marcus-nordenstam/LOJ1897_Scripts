; WALK_TO - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self WALK_TO ?target}
  (motor legs)
  (obs)
  (belief_timeout 600)
  (tar @excl)
  (presentation
    (state walking)
    (movement-speed 0.1)
    (delib-turn-speed 4.0)
    (preroll 0.0) (in 0.4) (out 0.4)))
