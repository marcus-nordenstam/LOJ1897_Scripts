; OFFER - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self OFFER ?target}
  (duration procedural)
  (motor right-hand)
  (obs)
  (tar @excl)
  (construed-act provision-act)
  (presentation
    (preroll 0.0) (in 0.3) (out 0.3)))
