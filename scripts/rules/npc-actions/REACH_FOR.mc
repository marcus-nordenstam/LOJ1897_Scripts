; REACH_FOR - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self REACH_FOR ?target ?aux}
  (sided aux left_arm right_arm)
  (obs)
  (tar @excl)
  (presentation
    (proc-anim reachfor)
    (preroll 0.0) (in 1) (out 1)))
