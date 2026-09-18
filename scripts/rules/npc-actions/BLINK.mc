; BLINK - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self BLINK ?target}
  (duration 0.3)
  (motor eyelid)
  (obs)
  (tar @excl)
  (presentation
    (proc-anim blink)
    (preroll 0.0) (in 0.0) (out 0.0)))
