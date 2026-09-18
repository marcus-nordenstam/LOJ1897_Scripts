; WRITE_DOC - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self WRITE_DOC ?target ?aux}
  (duration procedural)
  (motor right-hand)
  (obs)
  (tar @excl)
  (aux @msg @excl)
  (presentation
    (preroll 0.0) (in 0.4) (out 0.4)))
