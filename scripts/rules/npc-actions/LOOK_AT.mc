; LOOK_AT - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self LOOK_AT ?target}
  (duration procedural)
  (motor head)
  (obs)
  (tar @excl)
  (presentation
    (proc-anim lookat)
    (preroll 0.0) (in 2) (out 2)))
