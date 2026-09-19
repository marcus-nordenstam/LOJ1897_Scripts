; HAND-DRINK - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (init ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self HAND-DRINK ?target}
  (duration 1)
  (sided target left-hand right-hand)
  (obs)
  (tar @excl)
  (construed-act aid-act)
  (presentation
    (anim right_drink)
    (anim-flags loop reset)
    (preroll 0) (in 1) (out 1)))
