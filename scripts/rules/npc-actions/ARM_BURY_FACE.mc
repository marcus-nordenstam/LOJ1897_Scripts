; ARM_BURY_FACE - the act, its motor and how it looks. Its BODY is still the C++ handler
;   registered under this label; it becomes (prelude ..) / (effects ..) / (cease ..)
;   when this action is scripted (docs/plans/action_unification_plan.md).

(npc-action {@self ARM_BURY_FACE ?target}
  (duration procedural)
  (sided target left_arm right_arm)
  (obs)
  (tar @excl)
  (presentation
    (anim-left left_hand_bury_face)
    (anim-right right_hand_bury_face)
    (anim-flags loop reset)
    (preroll 0.0) (in 0.4) (out 0.4)))
